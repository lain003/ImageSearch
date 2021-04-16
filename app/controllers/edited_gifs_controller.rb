# frozen_string_literal: true

class EditedGifsController < ApplicationController
  def new
    @meta_frame = MetaFrame.find(params[:id])
  end

  def show
    @meta_frame = MetaFrame.find(params[:id])
    @edited_gif = EditedGif.find(params[:edited_gif_id])
  end

  def create # rubocop:disable Metrics/AbcSize
    meta_frame = MetaFrame.find(params[:id])

    form = CreateForm.new(start_frame: params['gif_length']['start_frame'].to_i,
                          end_frame: params['gif_length']['end_frame'].to_i)
    edited_gif = form.create(meta_frame)

    if form.errors.any?
      redirect_to action: 'new', id: meta_frame.id
    else
      redirect_to action: 'show', id: meta_frame.id, edited_gif_id: edited_gif.id
    end
  end
end

class CreateForm
  include ActiveModel::Model
  attr_accessor :start_frame, :end_frame

  validates :start_frame, :end_frame, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  # @return [EditedGif]
  def create(meta_frame)
    file_name = SecureRandom.urlsafe_base64
    local_path = "tmp/edited_gif/#{file_name}.gif"
    cut_gif(meta_frame, local_path)
    edited_gif = EditedGif.new(meta_frame: meta_frame, start_frame: start_frame, end_frame: end_frame, file_name: file_name)
    edited_gif.upload_image(local_path)
    File.delete(local_path)
    edited_gif.save!
    edited_gif
  end

  private

  def cut_gif(meta_frame, local_path)
    FileUtils.mkdir_p('tmp/edited_gif') unless File.exist?('tmp/edited_gif')
    system('wget', "http://#{Settings.bucket_name}/#{meta_frame.cloud_gif_path}")
    option = "trim=start_frame=#{start_frame}:end_frame=#{end_frame + 1},setpts=PTS-STARTPTS,scale=640:-1,split[a][b];[a]palettegen[pal];[b][pal]paletteuse"
    system('ffmpeg', '-i', "#{meta_frame.image_num}.gif", '-vf', option, local_path)
    system('rm', "#{meta_frame.image_num}.gif")
  end
end
