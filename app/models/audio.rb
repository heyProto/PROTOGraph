# == Schema Information
#
# Table name: audios
#
#  id            :integer          not null, primary key
#  account_id    :integer
#  name          :string(255)
#  audio         :string(255)
#  description   :text(65535)
#  s3_identifier :string(255)
#  total_time    :integer
#  created_by    :integer
#  updated_by    :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Audio < ApplicationRecord
  #CONSTANTS
  #CUSTOM TABLES

  #GEMS
  paginates_per 24
  
  #CONCERNS
  include Propagatable
  include AssociableByAc
  
  #ASSOCIATIONS
  delegate :account, to: :image
  has_many :audio_variation, -> {where.not(is_original: true)}, dependent: :destroy
  has_one :original_audio, -> {where(is_original: true)}, class_name: "AudioVariation", foreign_key: "audio_id"
  has_many :activities
  mount_uploader :audio, AudioUploader
  #ACCESSORS
  #VALIDATIONS
  #CALLBACKS
  before_create { self.s3_identifier = SecureRandom.hex(8) }
  after_commit :create_audio_version, on: :create
  #SCOPE
  #OTHER

  def as_json(options = {})
    {
      id: self.id,
      redirect_to: Rails.application.routes.url_helpers.account_audio_path(self.account_id, self),
      audio_url: self.original_audio.audio_url,
      total_time: self.total_time
    }
  end

  def audio_url
    self.original_audio.audio_url
  end

  def create_audio_version
    options = {
      audio_id: self.id,
      is_original: true,
      created_by: created_by,
      updated_by: updated_by
    }

    AudioVariation.create!(options)
  end

  #PRIVATE
end
