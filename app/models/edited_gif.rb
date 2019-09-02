# frozen_string_literal: true

# == Schema Information
#
# Table name: edited_gifs
#
#  id            :integer          not null, primary key
#  file_name     :string
#  meta_frame_id :integer
#  start_frame   :integer
#  end_frame     :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class EditedGif < ApplicationRecord
  belongs_to :meta_frame

  # @return [string]
  def cloud_url
    'http://' + Settings.bucket_name + '/' + cloud_path
  end

  # @return [string]
  def cloud_path
    meta_frame.root_path + '/edited_gif' + '/' + file_name + '.gif'
  end

  def upload_image(local_path)
    storage = Google::Cloud::Storage.new(project_id: Settings.gcp_project_id, credentials: Settings.gcp_credentials)
    bucket = storage.bucket Settings.bucket_name
    file = bucket.create_file(local_path, cloud_path)
    file.acl.public!
  end
end
