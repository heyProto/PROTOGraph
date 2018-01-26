# == Schema Information
#
# Table name: sites
#
#  id                   :integer          not null, primary key
#  account_id           :integer
#  name                 :string(255)
#  domain               :string(255)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  description          :text(65535)
#  primary_language     :string(255)
#  default_seo_keywords :text(65535)
#  house_colour         :string(255)
#  reverse_house_colour :string(255)
#  font_colour          :string(255)
#  reverse_font_colour  :string(255)
#  stream_url           :text(65535)
#  stream_id            :integer
#  cdn_provider         :string(255)
#  cdn_id               :string(255)
#  host                 :text(65535)
#  cdn_endpoint         :text(65535)
#  client_token         :string(255)
#  access_token         :string(255)
#  client_secret        :string(255)
#  facebook_url         :text(65535)
#  twitter_url          :text(65535)
#  instagram_url        :text(65535)
#  youtube_url          :text(65535)
#  g_a_tracking_id      :string(255)
#  favicon_id           :integer
#  logo_image_id        :integer
#  sign_up_mode         :string(255)
#  default_role         :string(255)
#  story_card_style     :string(255)
#  email_domain         :string(255)
#

class Site < ApplicationRecord
    #CONSTANTS
    SIGN_UP_MODES = ["Any email from your domain", "Invitation only"]
    #CUSTOM TABLES
    #GEMS
    #ASSOCIATIONS
    belongs_to :account
    has_many :folders
    has_many :streams
    has_many :activities
    has_many :ref_categories
    has_many :ref_tags
    has_many :view_casts
    has_many :pages
    has_one :stream, primary_key: "stream_id", foreign_key: "id"
    belongs_to :logo_image, class_name: "Image", foreign_key: "logo_image_id", primary_key: "id", optional: true
    belongs_to :favicon, class_name: "Image", foreign_key: "favicon_id", primary_key: "id", optional: true
    has_many :permissions, ->{where(status: "Active", permissible_type: 'Site')}, foreign_key: "permissible_id", dependent: :destroy
    has_many :users, through: :permissions
    has_many :permission_invites, ->{where(permissible_type: 'Site')}, foreign_key: "permissible_id", dependent: :destroy

    #ACCESSORS
    accepts_nested_attributes_for :logo_image, :favicon
    #VALIDATIONS
    # validates :name, presence: true, uniqueness: {scope: :account}

    validates :domain, format: {:with => /[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]\.[a-zA-Z]{2,}/ }, allow_blank: true, allow_nil: true, length: { in: 3..240 }, exclusion: { in: %w(gmail.com outlook.com yahoo.com mail.com),
    message: "%{value} is reserved." }
    # validates :facebook_url, format: {:with => /[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]\.[a-zA-Z]{2,}/ }, allow_blank: true, allow_nil: true, length: { in: 9..240 }
    # validates :twitter_url, format: {:with => /[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]\.[a-zA-Z]{2,}/ }, allow_blank: true, allow_nil: true, length: { in: 9..240 }
    # validates :instagram_url, format: {:with => /[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]\.[a-zA-Z]{2,}/ }, allow_blank: true, allow_nil: true, length: { in: 9..240 }
    # validates :youtube_url, format: {:with => /[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]\.[a-zA-Z]{2,}/ }, allow_blank: true, allow_nil: true, length: { in: 9..240 }

    #CALLBACKS
    before_create :before_create_set
    before_update :before_update_set
    # after_create :after_create_set
    #SCOPE
    #OTHER
    #PRIVATE
    def is_cdn_id_from_env?
        self.cdn_id == ENV['AWS_CDN_ID']
    end

    def is_host_from_env?
        self.host == "#{AWS_API_DATACAST_URL}/cloudfront/invalidate"
    end

    def is_cdn_endpoint_from_env?
        self.cdn_endpoint == ENV['AWS_S3_ENDPOINT']
    end

    def is_client_token_from_env?
        self.client_token == ENV['AWS_ACCESS_KEY_ID']
    end

    def is_client_secret_from_env?
        self.client_secret == ENV['AWS_SECRET_ACCESS_KEY']
    end

    def create_sudo_permission(role)
        pykih_admins = {}
        User.where(email: ["ritvvij.parrikh@pykih.com", "ab@pykih.com", "dhara.shah@pykih.com"]).each do |user|
            pykih_admins[user.email] = user
        end

        pykih_admins.each do |email, user|
            user.create_permission("Account", self.account_id, "owner",true)
        end
    end



    private


    def before_create_set
        self.house_colour = "#EE1C25"
        self.reverse_house_colour = "#4caf50"
        self.font_colour = "#FFFFFF"
        self.reverse_font_colour = "#FFFFFF"
        self.cdn_provider = "CloudFront"
        self.cdn_id = ENV['AWS_CDN_ID']
        self.host = "#{AWS_API_DATACAST_URL}/cloudfront/invalidate"
        self.cdn_endpoint = ENV['AWS_S3_ENDPOINT']
        self.client_token = ENV['AWS_ACCESS_KEY_ID']
        self.client_secret = ENV['AWS_SECRET_ACCESS_KEY']
        self.story_card_style = 'Clear: Color'
        self.default_role = 'writer'
        true
    end

    def before_update_set
        self.cdn_endpoint = ENV['AWS_S3_ENDPOINT'] if self.cdn_endpoint.blank?
        self.client_token = ENV['AWS_ACCESS_KEY_ID'] if self.client_token.blank?
        self.client_secret = ENV['AWS_SECRET_ACCESS_KEY'] if self.client_secret.blank?
        self.host = "#{AWS_API_DATACAST_URL}/cloudfront/invalidate" if self.host.blank?
        self.cdn_id = ENV['AWS_CDN_ID'] if self.cdn_id.blank? and self.cdn_endpoint == ENV['AWS_S3_ENDPOINT']
        true
    end

    def after_create_set
        user_id = account.users.present? ? account.users.first.id : nil
        stream = Stream.create!({
            is_automated_stream: true,
            col_name: "Site",
            col_id: self.id,
            updated_by: user_id,
            created_by: user_id,
            account_id: account_id,
            title: self.name,
            description: "#{self.name} stream",
            limit: 50
        })

        self.update_columns(stream_url: "#{self.cdn_endpoint}/#{stream.cdn_key}", stream_id: stream.id)
        create_sudo_permission("owner")
    end
end
