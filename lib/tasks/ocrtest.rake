# frozen_string_literal: true

require 'google/cloud/vision'
require 'google/cloud/storage'
require 'json'
require 'rexml/document'

namespace :ocrtest do # rubocop:disable Metrics/BlockLength
  desc 'MKVを元にGCPに画像をアップロードする'
  task upload_screenshot: :environment do
    identifier = 'kill_la_kill'
    mkv_file_paths = Dir.glob("tmp/movies/#{identifier}/**/*.mkv")
    mkv_file_paths.each do |mkv_file_path|
      season = mkv_file_path.split('/')[3]
      episode = mkv_file_path.split('/')[4]
      work_folder = "tmp/ocr/#{identifier}/#{season}/#{episode}/"

      sub_index = get_index_jp_subtitle(mkv_file_path)

      sup_path = "#{work_folder}sup/"
      sup_file_path = output_sup(mkv_file_path, sup_path, sub_index)

      sup_png_path = "#{sup_path}png/"
      export_sup_png(sup_png_path, sup_file_path)

      union_sup_png_path = "#{sup_png_path}union/"
      FileUtils.mkdir_p(union_sup_png_path) unless FileTest.exist?(union_sup_png_path)

      screenshot_path = "#{work_folder}screenshot/"
      FileUtils.mkdir_p(screenshot_path)
      upload_screenshot(sup_png_path, "#{sup_png_path}main.xml", mkv_file_path, sub_index)
    end
  end

  desc 'GCPの画像データを元にDBにレコードを作成する'
  task register_imageinfo: :environment do
    storage = new_gcs_storage
    bucket = storage.bucket Settings.bucket_name
    identifier = 'kill_la_kill'
    serial = 1

    siry = Siry.find_or_create_by!(identifier: identifier, name: 'キルラキル')
    season = Season.find_or_create_by!(serial: serial, siry: siry)

    files = bucket.files prefix: "#{identifier}/#{serial}/", delimiter: 'gif'
    files.all.each do |file|
      paths = file.name.split('/')
      movie = Movie.find_or_create_by!(season: season, ep_num: paths[2])

      meta = file.metadata
      next if meta['text'].empty?

      p meta
      meta_frame = MetaFrame.find_or_initialize_by(movie: movie, start_sec: meta['start_sec'], end_sec: meta['end_sec'])
      meta_frame.image_num = paths[4].to_i
      meta_frame.text = meta['text']
      meta_frame.save!
    end
  end

  desc 'Gifのカット機能を、CSRFに引っかからずlocalhostからできるようにする'
  task change_cors: :environment do
    storage = new_gcs_storage
    bucket = storage.bucket Settings.bucket_name
    bucket.cors do |c|
      c.add_rule ['*'],
                 ['GET'],
                 headers: %w[Content-Type image/gif],
                 max_age: 3600
    end
  end

  desc 'GCPの画像データを元にGIFを作りGCPにあげる'
  task create_gif: :environment do
    storage = new_gcs_storage
    bucket = storage.bucket Settings.bucket_name
    identifier = 'kill_la_kill'
    serial = 1

    files = bucket.files prefix: "#{identifier}/#{serial}/", delimiter: 'gif'
    files.all.each do |file|
      p file.name
      paths = file.name.split('/')
      cloud_path = "#{paths[0]}/#{paths[1]}/#{paths[2]}/gif"
      next if bucket.file("#{cloud_path}/#{paths[4].to_i}.gif").present?

      work_folder = "tmp/ocr/#{cloud_path}"
      FileUtils.mkdir_p(work_folder) unless Dir.exist?(work_folder)

      mkv_path = "tmp/movies/#{paths[0]}/#{paths[1]}/#{paths[2]}/mkv/main.mkv"
      sub_index = get_index_jp_subtitle(mkv_path)
      local_file_name = "#{work_folder}/#{paths[4].to_i}.gif"

      `yes | ffmpeg -ss #{file.metadata['start_sec'].to_f - 1} -t 5 -i #{mkv_path} -filter_complex "[0:v][0:#{sub_index}]overlay,scale=640:-1,split[a][b];[a]palettegen[pal];[b][pal]paletteuse" -r 10 #{local_file_name}`

      local_eco_file_name = "#{work_folder}/#{paths[4].to_i}-eco.gif"
      command = "gifsicle #{local_file_name} --lossy=100 > #{local_eco_file_name}"
      `#{command}`

      file = bucket.create_file(local_eco_file_name,
                                "#{cloud_path}/#{paths[4].to_i}.gif")
      file.acl.public!
    end
  end
end

def get_index_jp_subtitle(local_movie_file_path)
  ffprobe_command = "ffprobe -v quiet -print_format json -show_streams #{local_movie_file_path}"
  movie_info = `#{ffprobe_command}`
  movie_info = JSON.parse(movie_info)
  subtitles_info = movie_info['streams'].map { |i| i if i['codec_type'] == 'subtitle' }.compact
  jp_subtitles = subtitles_info.map { |i| i if i['tags']['language'] == 'jpn' }.compact
  jp_subtitles.first['index']
end

def output_sup(movie_file_path, output_sup_path, sub_index)
  FileUtils.mkdir_p(output_sup_path) unless FileTest.exist?(output_sup_path)
  sup_file_path = "#{output_sup_path}mkv.sup"
  command = "yes | ffmpeg -i #{movie_file_path} -map 0:#{sub_index} -c copy #{sup_file_path}"
  `#{command}`
  sup_file_path
end

def export_sup_png(local_sup_png_path, local_sup_path)
  FileUtils.mkdir_p(local_sup_png_path) unless FileTest.exist?(local_sup_png_path)
  command = "yes | java -jar resource/BDSup2Sub.jar -o #{local_sup_png_path}main.xml #{local_sup_path}"
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

def imageinfos_union_and_upload(imageinfos, bucket, union_sup_png_path, gcs_sup_png_path)
  buffer_imageinfos = []
  imageinfos.each_with_index do |image_info, index|
    buffer_imageinfos << image_info
    total_y = buffer_imageinfos.inject(0) { |sum, i| sum + i.y }
    if total_y > 3000
      union_and_upload(buffer_imageinfos, bucket, union_sup_png_path, gcs_sup_png_path)
      buffer_imageinfos = []
    end
    if (index == imageinfos.size - 1) && !buffer_imageinfos.empty?
      union_and_upload(buffer_imageinfos, bucket, union_sup_png_path, gcs_sup_png_path)
      buffer_imageinfos = []
    end
  end
end

def union_and_upload(buffer_imageinfos, bucket, union_sup_png_path, gcs_sup_png_path) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  file_name = "#{SecureRandom.uuid}.png"
  local_file_path = union_sup_png_path + file_name
  gcs_sup_png_file_path = gcs_sup_png_path + file_name
  file_names = buffer_imageinfos.map { |file| file.path.to_s }
  files_string = file_names.join(' ')
  space = 40
  `convert -append #{files_string} -background none -splice 0x#{space} #{local_file_path}`

  meta_data = {}
  base_names = buffer_imageinfos.map { |file| file.path.basename.to_s }
  base_names = base_names.join(',')
  meta_data['names'] = base_names
  before_y = 0
  buffer_imageinfos.each do |image_info|
    y = before_y + space + image_info.y
    meta_data["x_#{image_info.path.basename}"] = image_info.x
    meta_data["y_#{image_info.path.basename}"] = y
    before_y = y
  end
  bucket.create_file local_file_path, gcs_sup_png_file_path, metadata: meta_data
end

def upload_screenshot(local_folder_path, local_sup_xml_path, local_movie_path, index_stream_sub) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  doc = REXML::Document.new(File.new(local_sup_xml_path))
  hash = Hash.from_xml(doc.to_s)
  events = hash['BDN']['Events']['Event']

  image_annotator = Google::Cloud::Vision::ImageAnnotator.new(credentials: Settings.gcp_credentials)

  Dir.glob("#{local_folder_path}*\\.png") do |path_name|
    identifier = path_name.split('/')[2]
    movie = path_name.split('/')[3]
    siri = path_name.split('/')[4]
    png_num = path_name.split('/')[7].delete('^0-9').to_i
    screenshot_path = "tmp/ocr/#{identifier}/#{movie}/#{siri}/screenshot/#{png_num}.png"
    next if File.exist?(screenshot_path)

    response = image_annotator.text_detection(image: path_name.to_s)
    text = response.responses[0].text_annotations[0].try(:description)

    target = events.select { |event| event['Graphic'] == File.basename(path_name) }.first
    in_time = convert_sec(target['InTC'])
    out_time = convert_sec(target['OutTC'])

    meta_data = { start_sec: in_time, end_sec: out_time, text: text }
    p meta_data
    upload_image(path_name, meta_data, local_movie_path, index_stream_sub)
  end
end

# @param meta_data {}
def upload_image(local_png_path, meta_data, local_movie_path, index_stream_sub) # rubocop:disable Metrics/AbcSize
  identifier = local_png_path.split('/')[2]
  movie = local_png_path.split('/')[3]
  siri = local_png_path.split('/')[4]
  png_num = local_png_path.split('/')[7].delete('^0-9').to_i

  screenshot_path = "tmp/ocr/#{identifier}/#{movie}/#{siri}/screenshot/#{png_num}.png"

  storage = new_gcs_storage
  bucket = storage.bucket Settings.bucket_name

  command = "yes | ffmpeg -ss #{meta_data[:start_sec]} -i #{local_movie_path} -filter_complex \"[0:v][0:#{index_stream_sub}]overlay\" -ss 0.7 -vframes 1 #{screenshot_path}"
  `#{command}`
  command2 = "pngquant --ext .png #{screenshot_path} -f --quality=50-50"
  `#{command2}`
  cloud_image_path = "#{identifier}/#{movie}/#{siri}/screenshot/#{png_num}.png"
  file = bucket.create_file(screenshot_path, cloud_image_path, metadata: meta_data)
  file.acl.public!
  p cloud_image_path
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
  micro_s = micro_s[0].sub(/:/, '')
  sec_s = sec_s.sub(/(:[0-9]+)$/, '')
  sec = sec_exchange(Time.zone.parse(sec_s))
  sec + micro_s.to_i / 100.0
end

def new_gcs_storage
  Google::Cloud::Storage.new(project_id: Settings.gcp_project_id,
                             credentials: Settings.gcp_credentials)
end
