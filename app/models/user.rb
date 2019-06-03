  # == Schema Information
#
# Table name: users
#
#  id                       :integer          not null, primary key
#  name                     :string(255)
#  email                    :string(255)
#  access_token             :string(255)
#  encrypted_password       :string(255)
#  reset_password_token     :string(255)
#  reset_password_sent_at   :datetime
#  remember_created_at      :datetime
#  sign_in_count            :integer          default(0), not null
#  current_sign_in_at       :datetime
#  last_sign_in_at          :datetime
#  current_sign_in_ip       :string(255)
#  last_sign_in_ip          :string(255)
#  confirmation_token       :string(255)
#  confirmed_at             :datetime
#  confirmation_sent_at     :datetime
#  unconfirmed_email        :string(255)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  can_publish_link_sources :boolean          default(FALSE)
#  bio                      :text
#  website                  :text
#  facebook                 :text
#  twitter                  :text
#  phone                    :string(255)
#  linkedin                 :text
#

class User < ApplicationRecord

    #CONSTANTS
    #CUSTOM TABLES
    #GEMS
    devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
    #CONCERNS
    #ASSOCIATIONS
    has_many :permissions, ->{where(status: "Active")}
    has_many :uploads
    has_many :user_emails

    #ACCESSORS
    attr_accessor :username, :domain

    #VALIDATIONS
    validates :name, presence: true, length: { in: 3..24 }
    validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: /\A[^@\s]+@([^@.\s]+\.)+[^@.\s]+\z/ }
    validate :email_invited, on: [:create]
    validates :website, format: {:with => /[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]\.[a-zA-Z]{2,}/ }, allow_blank: true, allow_nil: true, length: { in: 9..240 }
    validates :facebook, format: {:with => /[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]\.[a-zA-Z]{2,}/ }, allow_blank: true, allow_nil: true, length: { in: 9..240 }
    validates :twitter, format: {:with => /[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]\.[a-zA-Z]{2,}/ }, allow_blank: true, allow_nil: true, length: { in: 9..240 }
    validates :linkedin, format: {:with => /[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]\.[a-zA-Z]{2,}/ }, allow_blank: true, allow_nil: true, length: { in: 9..240 }

    #CALLBACKS
    before_create :before_create_set
    after_create :welcome_user
    after_commit :add_user_email, on: [:create]

    #SCOPE
    scope :online, -> { where('updated_at > ?', 10.minutes.ago) }

    #OTHER

    def permission_object(site_id, s="Active")
        Permission.where(user_id: self.id,  permissible_id: site_id, permissible_type: 'Site', status: s).first
    end

    def owner_role(site_id, s="Active")
        Permission.where(user_id: self.id,  permissible_id: site_id, permissible_type: 'Site', ref_role_slug: "owner", status: s).first
    end

    def is_admin_from_pykih
        ["r@pro.to", "nidhi@pro.to", "nasr@pro.to"].include?(self.email)
    end

    def create_permission(permissible_type, permissible_id, r, is_hidden=false)
        p = Permission.where(user_id: self.id, permissible_id: permissible_id, permissible_type: permissible_type).first
        if p.present?
            p.update_attributes(status: "Active", ref_role_slug: r, updated_by: self.id, is_hidden: is_hidden, name: self.name, bio: self.bio, meta_description: self.bio)
        else
            p = Permission.create(user_id: self.id, permissible_id: permissible_id, permissible_type: permissible_type, created_by: self.id,
                                  updated_by: self.id, ref_role_slug: r,is_hidden: is_hidden, name: self.name, bio: self.bio, meta_description: self.bio)
        end
        p
    end

    def online?
      updated_at > 10.minutes.ago
    end

    def add_user_email
      # All user emails are handled by UserEmail model.
      # The user_email created with the same email as
      # the user is created with is primary email
      UserEmail.create(
        user_id: self.id,
        email: self.email,
        confirmed_at: Time.now,
        is_primary_email: 1
      )
    end

    def sites
        site_ids = self.permissions.where(permissible_type: "Site").pluck(:permissible_id)
        Site.where(id: site_ids)
    end

    def folders(site)
        site.folders.where(id: self.permissions.where(permissible_type: "Folder").pluck(:permissible_id))
    end

    def view_casts(folder)
        # Change the code here
        folder.view_casts.where(id: self.permissions.where(permissible_type: "ViewCast").pluck(:permissible_id))
    end

    def streams(folder)
        # Change the code here
        folder.streams.where(id: self.permissions.where(permissible_type: "Stream").pluck(:permissible_id))
    end

    def pages(folder)
        # Change the code here
        folder.pages.where(id: self.permissions.where(permissible_type: "Page").pluck(:permissible_id))
    end

    def email_invited
        d = self.email.split("@").last
        if PermissionInvite.where(email: self.email).count == 0
            errors.add(:email, "Not invited.")
        end
    end


    class << self
        def check_for_access(email)
            is_present = PermissionInvite.where(email: email).first.present?
            return is_present
        end
    end
    #PRIVATE
    private


    def before_create_set
        self.access_token = SecureRandom.hex(24)
    end

    def welcome_user
        if Rails.env == "production"
            WelcomeUserWorker.perform_in(1.second, self.id)
        end
    end
end
