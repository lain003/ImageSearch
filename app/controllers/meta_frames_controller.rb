# frozen_string_literal: true

class MetaFramesController < ApplicationController
  def index # rubocop:disable Metrics/MethodLength
    words = words_params
    @search_form = SearchForm.new(words: words, page: params[:page])
    @meta_frames = @search_form.search
    @view_meta_frames = convert_view_metaframe(@meta_frames)
    @example_words = Settings.example_words
    @search_words = words.join(' ')
    title = "#{@search_words}の検索結果"
    @html_meta = HTMLMeta.new(title: title, description: title)
    @image_paths = { twitter: view_context.image_path('twitter.png'),
                     loading: view_context.image_path('loading.gif') }

    respond_to do |format|
      format.html
      format.json do
        render json: @view_meta_frames
      end
    end
  end

  def show
    @meta_frame = MetaFrame.find(params[:id])
    @html_meta = HTMLMeta.new(description: @meta_frame.description_text,
                              image_url: @meta_frame.image_url,
                              twitter_card: 'summary_large_image')
  end

  def select
    @meta_frame = MetaFrame.find(params[:id])
  end

  def gif
    @meta_frame = MetaFrame.find(params[:id])
  end

  private

  def convert_view_metaframe(meta_frames)
    meta_frames.includes(movie: [season: [:siry]]).map do |meta|
      { gif_path: Rails.application.routes.url_helpers.meta_frame_gif_path(meta.id),
        image_url: meta.image_url,
        gif_url: meta.gif_url,
        id: meta.id }
    end
  end

  def words_params
    return ['ようこそ'] if params[:words].blank?

    word = params[:words]
    word.split(/[[:blank:]]+/)
  end
end

class SearchForm
  include ActiveModel::Model

  attr_accessor :words, :page

  validate :custom_validate

  def custom_validate
    return if words.blank?

    words.each do |word|
      errors.add(:words, '記号は入力できません') unless word =~ /\A[ぁ-んァ-ンーa-zA-Z0-9一-龠０-９\-\r]+\z/
    end
  end

  # @return [Array<MetaFrame>]
  def search
    return Kaminari.paginate_array([]).page(1) if invalid? || words.blank?

    MetaFrame.synonym_search(words).page(page).records(includes: { movie: { season: :siry } })
  end
end
