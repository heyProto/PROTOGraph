# == Schema Information
#
# Table name: ref_categories
#
#  id                :integer          not null, primary key
#  site_id           :integer
#  genre             :string(255)
#  name              :string(255)
#  stream_url        :text(65535)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  stream_id         :integer
#  is_disabled       :boolean
#  created_by        :integer
#  updated_by        :integer
#  count             :integer          default(0)
#  name_html         :string(255)
#  slug              :string(255)
#  english_name      :string(255)
#  vertical_page_url :text(65535)
#  account_id        :integer
#  description       :text(65535)
#  keywords          :text(65535)
#

#TODO AMIT - Handle account_id - RP added retrospectively. Need migration of old rows and BAU handling.

class RefCategory < ApplicationRecord
    #CONSTANTS
    #CUSTOM TABLES
    #GEMS
    before_validation :before_validation_set
    extend FriendlyId
    friendly_id :english_name, use: :slugged
    #CONCERNS
    include Propagatable
    include AssociableByAcSi
    #ASSOCIATIONS
    has_one :stream, foreign_key: 'id', primary_key: 'stream_id'
    has_many :navigations, class_name: "SiteVerticalNavigation", foreign_key: "ref_category_vertical_id", dependent: :destroy
    has_one :folder, foreign_key: 'ref_category_vertical_id'
    has_many :pages, foreign_key: 'ref_category_series_id'
    #ACCESSORS
    #VALIDATIONS
    validates :name, presence: true, uniqueness: {scope: :site}, length: { in: 3..15 }
    validates :genre, inclusion: {in: ["intersection", "sub intersection", "series"]}

    #CALLBACKS
    before_create :before_create_set

    after_create :after_create_set
    before_update :before_update_set
    after_destroy :update_site_verticals
    after_update :update_site_verticals
    #SCOPE
    #OTHER

    def should_generate_new_friendly_id?
        self.slug.nil? || english_name_changed?
    end

    def vertical_page
        self.pages.where(template_page_id: TemplatePage.where(name: "Homepage: Vertical").first.id).first
    end

    # def vertical_page_url
    #     "#{self.site.cdn_endpoint}/#{self.slug}.html"
    # end

    def view_casts
        ViewCast.where("#{genre}": self.name)
    end

    def vertical_header_key
        "#{self.slug}/navigation.json"
    end

    def vertical_header_url
        "#{self.site.cdn_endpoint}/#{vertical_header_key}"
    end

    def update_site_verticals
        Thread.new do
            verticals_json = []
            self.site.verticals.each do |ver|
                next unless ver.vertical_page.present? and ver.vertical_page.is_published
                verticals_json << {"name": "#{ver.name}","url": "#{ver.vertical_page_url}","new_window": true, "name_html": "#{ver.name_html}"}
            end
            key = "#{self.site.homepage_header_key}"
            encoded_file = Base64.encode64(verticals_json.to_json)
            content_type = "application/json"
            resp = Api::ProtoGraph::Utility.upload_to_cdn(encoded_file, key, content_type, self.site.cdn_bucket)
            Api::ProtoGraph::CloudFront.invalidate(self.site, ["/#{key}"], 1)
            ActiveRecord::Base.connection.close
        end
    end

    def before_validation_set
        self.english_name = self.name if self.site.is_english
    end

    #PRIVATE
    private

    def before_create_set
        self.vertical_page_url = "#{self.site.cdn_endpoint}/#{self.slug}.html" if self.vertical_page_url.blank?
        true
    end

    def before_update_set
        self.is_disabled = true if self.count > 0
        self.english_name = ActionView::Base.full_sanitizer.sanitize(self.english_name)
        self.name_html = self.name if self.name_html.blank?
        true
    end

    def after_create_set
        # s = Stream.create!({
        #     is_automated_stream: true,
        #     col_name: "RefCategory",
        #     col_id: self.id,
        #     account_id: self.site.account_id,
        #     title: self.name,
        #     description: "#{self.name} stream",
        #     limit: 50
        # })

        # Thread.new do
        #     s.publish_cards
        #     ActiveRecord::Base.connection.close
        # end

        # self.update_columns(stream_url: "#{s.site.cdn_endpoint}/#{s.cdn_key}", stream_id: s.id)

        # Create a new page object
        page = Page.create({account_id: self.site.account_id,
            site_id: self.site_id,
            headline: "#{self.name + " "*(50 - (self.name.length)) }",
            template_page_id: TemplatePage.where(name: 'Homepage: Vertical').first.id,
            ref_category_series_id: self.id,
            created_by: self.created_by,
            updated_by: self.updated_by,
            datacast_identifier: '',
            url: "#{vertical_page_url}"
        })
        page.push_json_to_s3
        #Update the site vertical json
        update_site_verticals
        key = self.vertical_header_key
        encoded_file = Base64.encode64([].to_json)
        content_type = "application/json"
        resp = Api::ProtoGraph::Utility.upload_to_cdn(encoded_file, key, content_type, self.site.cdn_bucket)
    end

end
