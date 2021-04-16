# frozen_string_literal: true

# == Schema Information
#
# Table name: meta_frames
#
#  id         :integer          not null, primary key
#  movie_id   :integer
#  start_sec  :float            not null
#  end_sec    :float            not null
#  text       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'elasticsearch/model'
require 'google/cloud/storage'

module Searchable
  extend ActiveSupport::Concern

  included do # rubocop:disable Metrics/BlockLength
    include Elasticsearch::Model

    settings index: {
      number_of_shards: 1,
      number_of_replicas: 0,
      analysis: {
        tokenizer: {
          ja_normal_tokenizer: {
            type: 'kuromoji_tokenizer',
            mode: 'normal'
          },
          base_form_tokenizer: {
            type: 'kuromoji_tokenizer'
          }
        },
        analyzer: {
          ja_normal_analyzer: {
            type: 'custom',
            tokenizer: 'ja_normal_tokenizer'
          },
          base_form_analyzer: {
            tokenizer: 'kuromoji_tokenizer',
            filter: [
              'kuromoji_baseform'
            ]
          }
        }
      }
    } do
      mapping dynamic: 'false' do
        indexes :text, type: 'text', analyzer: 'ja_normal_analyzer'
        indexes :base_form, type: 'text', analyzer: 'base_form_analyzer'
      end
    end

    # @param words [Array[Synonym]]
    def self.search(words)
      must_params = []
      words.each do |word|
        should_params = []
        should_params << { terms: { base_form: [word.base_word], boost: 2 } }
        should_params << { terms: { base_form: word.synonym_words } } unless word.synonym_words.nil?
        must_params << { bool: { should: should_params } }
      end
      param = { query: { bool: { must: must_params } } }
      __elasticsearch__.search(param)
    end

    def self.synonym_search(words)
      synonyms = []
      mecab = Natto::MeCab.new
      words.each do |word|
        synonyms += Synonym.get_synonym_and_tokenize(word, mecab)
      end
      MetaFrame.search(synonyms)
    end
  end
end

class MetaFrame < ApplicationRecord
  include Searchable

  belongs_to :movie

  def as_indexed_json(_options = {})
    { base_form: text }
  end

  # @return [string]
  def cloud_image_path
    "#{root_path}/screenshot/#{image_num}.png"
  end

  # @return [string]
  def cloud_gif_path
    "#{root_path}/gif/#{image_num}.gif"
  end

  # @return [string]
  def image_url
    "http://#{Settings.bucket_name}/#{cloud_image_path}"
  end

  # @return [string]
  def gif_url
    "http://#{Settings.bucket_name}/#{cloud_gif_path}"
  end

  # @return [string]
  def root_path
    "#{movie.season.siry.identifier}/#{movie.season.serial}/#{movie.ep_num}"
  end

  def description_text
    "[#{movie.season.siry.name}]#{text}"
  end

  # @param local_gif_path [string]
  # @param bucket [Google::Cloud::Storage::Bucket]
  def upload_gif(local_gif_path, bucket)
    file = bucket.create_file(local_gif_path, cloud_gif_path)
    file.acl.public!
  end

  # @param local_image_path [string]
  # @param bucket [Google::Cloud::Storage::Bucket]
  def upload_image(local_image_path, bucket)
    file = bucket.create_file(local_image_path, cloud_image_path)
    file.acl.public!
  end

  # @param bucket [Google::Cloud::Storage::Bucket]
  def delete_image(bucket)
    file = bucket.find_file(cloud_image_path)
    file.delete
  end

  # @param bucket [Google::Cloud::Storage::Bucket]
  def delete_gif(bucket)
    file = bucket.find_file(cloud_gif_path)
    file.delete
  end
end
