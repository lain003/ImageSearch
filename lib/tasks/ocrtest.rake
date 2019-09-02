# encoding: utf-8

require 'google/cloud/vision'
require 'google/cloud/storage'
require 'json'
require 'rexml/document'

namespace :ocrtest do
  desc ''
  task run: :environment do
    identifier = "kill_la_kill"
    name = "キルラキル"
    serial = 1
    index_stream_sub = 3

    storage = new_gcs_storage
    bucket = storage.bucket Settings.bucket_name
    gcs_root_path = identifier + "/" + serial.to_s + "/"
    files = bucket.files prefix:gcs_root_path + "movies"
    mkv_files = files.map{|i| i if File.extname(i.name) == ".mkv"}.compact
    siry = Siry.find_or_create_by(name:name,identifier: identifier)
    season = Season.find_or_create_by(serial:serial, siry:siry)
    mkv_files.each do |mkv_file|
      name = File.basename(mkv_file.name,".mkv")
      movie = Movie.find_or_create_by(season_id:season.id, ep_num:name.to_i)

      work_folder = "tmp/" + identifier + "/" + serial.to_s + "/" + movie.ep_num.to_s + "/"
      movie_folder = work_folder + "mkv/"
      movie_file_path = movie_folder + "main.mkv"
      movie_download(mkv_file,movie_file_path,movie_folder)

      sub_index = get_index_jp_subtitle(movie_file_path)

      sup_path = work_folder + "sup/"
      sup_file_path = output_sup(movie_file_path,sup_path,sub_index)

      sup_png_path = sup_path + "png/"
      export_sup_png(sup_png_path,sup_file_path)

      gcs_sub_png_path = gcs_root_path + movie.ep_num.to_s + "/sup/png/"
      union_sup_png_path = sup_png_path + "union/"
      FileUtils.mkdir_p(union_sup_png_path) unless FileTest.exist?(union_sup_png_path)
      upload_sup_png(bucket, gcs_sub_png_path, sup_png_path,union_sup_png_path)

      screenshot_path = work_folder + "screnshot/"
      FileUtils.mkdir_p(screenshot_path) unless FileTest.exist?(screenshot_path)

      create_metaframe_with_ocr_from_sub(bucket,gcs_sub_png_path,sup_png_path + "main.xml",
                                         movie,movie_file_path,screenshot_path,sub_index)
    end
  end

  task change_public_acl: :environment do
    storage = new_gcs_storage
    bucket = storage.bucket Settings.bucket_name
    Siry.all.each do |siry|
      siry.seasons.each do |season|
        season.movies.each do |movie|
          path = siry.identifier + "/" + season.serial.to_s + "/" + movie.ep_num.to_s + "/screenshot/"
          p path
          files = bucket.files prefix:path
          files.each do |file|
            file.acl.public!
          end
        end
      end
    end
  end

  task create_gif: :environment do
    storage = new_gcs_storage
    bucket = storage.bucket Settings.bucket_name

    Siry.all.each do |siry|
      next if siry.id == 1
      next if siry.id == 2
      next if siry.id == 3
      siry.seasons.each do |season|
        season.movies.each do |movie|
          cloud_path = siry.identifier + "/" + season.serial.to_s + "/" + movie.ep_num.to_s + "/gif"
          work_folder = "tmp/" + cloud_path
          unless Dir.exist?(work_folder) then
            FileUtils.mkdir_p(work_folder)
          end

          mkv_path = "tmp/" + siry.identifier + "/" + season.serial.to_s + "/" + movie.ep_num.to_s + "/mkv/main.mkv"
          sub_index = get_index_jp_subtitle(mkv_path)
          movie.meta_frames.each do |meta_frame|
            local_file_name = work_folder + "/" + meta_frame.id.to_s + ".gif"
            if File.exist?(local_file_name) then
              next
            end

            command = 'yes | ffmpeg -ss ' + (meta_frame.start_sec-1).to_s + ' -t 5 -i ' + mkv_path + ' -filter_complex "[0:v][0:' \
            + sub_index.to_s + ']overlay,scale=640:-1,split[a][b];[a]palettegen[pal];[b][pal]paletteuse" -r 10 ' + local_file_name
            `#{command}`
            file = bucket.create_file(local_file_name, cloud_path + "/" + meta_frame.id.to_s + ".gif")
            file.acl.public!

            p local_file_name
          end
        end
      end
    end
  end
end

def movie_download(bucket_file,movie_file_path,movie_folder)
  unless File.exist?(movie_file_path) then
    FileUtils.mkdir_p(movie_folder) unless FileTest.exist?(movie_folder)
    p bucket_file.name + " start download"
    bucket_file.download(movie_file_path)
  end
end

def get_index_jp_subtitle(local_movie_file_path)
  ffprobe_command = 'ffprobe -v quiet -print_format json -show_streams ' + local_movie_file_path
  movie_info = `#{ffprobe_command}`
  movie_info = JSON.parse(movie_info)
  subtitles_info = movie_info['streams'].map { |i| i if i['codec_type'] == 'subtitle' }.compact
  jp_subtitles = subtitles_info.map { |i| i if i['tags']['language'] == 'jpn' }.compact
  return jp_subtitles.first['index']
end

def output_sup(movie_file_path,output_sup_path,sub_index)
  FileUtils.mkdir_p(output_sup_path) unless FileTest.exist?(output_sup_path)
  sup_file_path = output_sup_path + "mkv.sup"
  command = 'yes | ffmpeg -i ' + movie_file_path + ' -map 0:' + sub_index.to_s + ' -c copy ' + sup_file_path
  `#{command}`
  sup_file_path
end

def export_sup_png(local_sup_png_path,local_sup_path)
  FileUtils.mkdir_p(local_sup_png_path) unless FileTest.exist?(local_sup_png_path)
  command = "yes | java -jar resource/BDSup2Sub.jar -o " + local_sup_png_path + "main.xml " + local_sup_path
  `#{command}`
end

# @path [Pathname]
# @x [int]
# @y [int]
class ImageInfo
  attr_accessor :path, :x, :y
  def initialize(path, x, y)
    self.path = path
    self.x = x
    self.y = y
  end
end

def upload_sup_png(bucket, gcs_sup_png_path, local_folder_path,union_sup_png_path)
  x_imageinfos = []
  y_imageinfos = []
  Dir.glob(local_folder_path + '*\.png') do |path_name|
    p path_name
    path_name = Pathname.new(path_name)
    image_size = FastImage.size(path_name)
    image_info = ImageInfo.new(path_name,image_size[0],image_size[1])
    if image_info.x < image_info.y
      y_imageinfos << image_info
    else
      x_imageinfos << image_info
    end
  end

  files = bucket.files prefix:gcs_sup_png_path
  files.each do |file| file.delete end

  imageinfos_union_and_upload(x_imageinfos,bucket,union_sup_png_path,gcs_sup_png_path)
  imageinfos_union_and_upload(y_imageinfos,bucket,union_sup_png_path,gcs_sup_png_path)
end

def imageinfos_union_and_upload(imageinfos,bucket,union_sup_png_path,gcs_sup_png_path)
  buffer_imageinfos = []
  imageinfos.each_with_index do |image_info,index|
    buffer_imageinfos << image_info
    total_y = buffer_imageinfos.inject(0){|sum,i| sum + i.y}
    if total_y > 3000
      union_and_upload(buffer_imageinfos,bucket,union_sup_png_path,gcs_sup_png_path)
      buffer_imageinfos = []
    end
    if index == imageinfos.size - 1 and not buffer_imageinfos.empty?
      union_and_upload(buffer_imageinfos,bucket,union_sup_png_path,gcs_sup_png_path)
      buffer_imageinfos = []
    end
  end
end

def union_and_upload(buffer_imageinfos,bucket,union_sup_png_path,gcs_sup_png_path)
  file_name = SecureRandom.uuid + ".png"
  local_file_path = union_sup_png_path + file_name
  gcs_sup_png_file_path = gcs_sup_png_path + file_name
  file_names = buffer_imageinfos.map{|file| file.path.to_s}
  files_string = file_names.join(' ')
  space = 40
  command = "convert -append " + files_string + " -background none -splice 0x" + space.to_s + " " + local_file_path
  `#{command}`

  meta_data = {}
  base_names = buffer_imageinfos.map{|file| file.path.basename.to_s}
  base_names = base_names.join(',')
  meta_data["names"] = base_names
  before_y = 0
  buffer_imageinfos.each do |image_info|
    y = before_y + space + image_info.y
    meta_data["x_" + image_info.path.basename.to_s] = image_info.x
    meta_data["y_" + image_info.path.basename.to_s] = y
    before_y = y
  end

  bucket.create_file local_file_path,gcs_sup_png_file_path,metadata:meta_data
end

def create_metaframe_with_ocr_from_sub(bucket,gcs_png_folder_path,local_sup_xml_path,movie,local_movie_path,screenshot_path,index_stream_sub)
  ocr_client = Google::Cloud::Vision.new(project_id: Settings.gcp_project_id)

  doc = REXML::Document.new(File.new(local_sup_xml_path))
  hash = Hash.from_xml(doc.to_s)
  events = hash['BDN']['Events']['Event']

  files = bucket.files prefix:gcs_png_folder_path
  files.all do |file|
    p file.name + " OCR..."
    begin
      ocr_text = ocr_client.image(file).text
      next if ocr_text.nil?
      file_names = file.metadata["names"].split(",")
      before_y = 0
      file_names.each do |file_name|
        target = events.select { |hash| hash['Graphic'] == file_name }.first
        in_time = convert_sec(target['InTC'])
        out_time = convert_sec(target['OutTC'])

        max_y = file.metadata["y_" + file_name].to_i
        words = ocr_text.to_h[:words]
        target_words = words.select{|word| before_y < word[:bounds][0][:y] && word[:bounds][0][:y] <= max_y}

        before_y = max_y

        target_text = target_words.map{|word| word[:text]}.join()
        next if target_text.blank?

        meta_frame = MetaFrame.find_by(movie_id: movie.id, start_sec: in_time,
                                       end_sec: out_time)
        next unless meta_frame.nil?

        meta_frame = MetaFrame.create(movie_id: movie.id, start_sec: in_time,
                                      end_sec: out_time, text: target_text)

        upload_image(meta_frame,local_movie_path,screenshot_path,index_stream_sub)
      end

    rescue => e
      raise e
    end
  end
end

# @param meta_frame [MetaFrame]
def upload_image(meta_frame,local_movie_path,local_save_screenshot_folder_path,index_stream_sub)
  local_png_path = local_save_screenshot_folder_path + meta_frame.file_name
  storage = new_gcs_storage
  bucket = storage.bucket Settings.bucket_name
  command = 'yes | ffmpeg -ss ' + (meta_frame.start_sec).to_s + ' -i ' +
      local_movie_path + ' -filter_complex "[0:v][0:'+ index_stream_sub.to_s + ']overlay" -ss 0.7 -vframes 1 ' + local_png_path
  `#{command}`
  file = bucket.create_file(local_png_path, meta_frame.cloud_image_path)
  file.acl.public!
end

# @param time [Time]
# @return [int]
def sec_exchange(time)
  time.hour * 60 * 60 + time.min * 60 + time.sec
end

# @param sec_s [string]
# @return [float]
def convert_sec(sec_s)
  micro_s = sec_s.match(/(:[0-9]+)$/)
  micro_s = micro_s[0].sub(/\:/,'')
  sec_s = sec_s.sub(/(:[0-9]+)$/,'')
  sec = sec_exchange(Time.parse(sec_s))
  sec + micro_s.to_i / 100.0
end

def new_gcs_storage
  return Google::Cloud::Storage.new(project_id: Settings.gcp_project_id, credentials: Settings.gcp_credentials)
end