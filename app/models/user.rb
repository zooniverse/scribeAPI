class User
  include Mongoid::Document
  include Mongoid::Timestamps
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable


  devise :omniauthable, :omniauth_providers => [:facebook,:google,:zooniverse]


  ## Database authenticatable
  field :email,              :type => String, :default => ""
  field :encrypted_password, :type => String, :default => ""

  ## Recoverable
  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Trackable
  field :name,               :type => String
  field :sign_in_count,      :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip,    :type => String

  field :uid,                :type => String
  field :provider,           :type => String

  has_many :favourites
  has_many :classifications

  ## Confirmable
  # field :confirmation_token,   :type => String
  # field :confirmed_at,         :type => Time
  # field :confirmation_sent_at, :type => Time
  # field :unconfirmed_email,    :type => String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, :type => Integer, :default => 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    :type => String # Only if unlock strategy is :email or :both
  # field :locked_at,       :type => Time

  def has_favourite?(subject)
    favourites.where( subject_id: subject.id ).exists?
  end

  def recents(limit=10)
    classifications.order_by(created_at: 1).limit(limit)
  end

  def recents_for_workflow(workflow, limit=10)
    recents(limit).where(workflow_id: workflow.id)
  end


  def self.find_for_oauth(access_token, signed_in_resource=nil)

    if user = self.find_by({provider: access_token[:provider], uid: access_token[:uid]})
      user
    else # Create a user with a stub password.
      details = details_from_oauth access_token[:provider], access_token
      binding.pry
      tmp_pass = Devise.friendly_token[0,20]
      self.create details.merge(password: tmp_pass, password_confirmation: tmp_pass)
    end
  end

  def self.details_from_oauth(provider,access_token)
      case provider
      when "facebook"
        details_from_fb(access_token)
      when "google"
        details_from_google(access_token)
      when "zooniverse"
        details_from_zooniverse(access_token)
      end
  end

  def self.details_from_fb(access_token)
    extra = access_token[:extra][:raw_info]
    {
      name: "#{extra[:first_name]} #{extra[:last_name]}",
      email: extra[:email],
      uid: access_token[:uid],
      provider: access_token[:provider]
    }
  end

  def self.details_from_google(access_token)
    {
      name: "#{extra[:first_name]} #{extra[:last_name]}",
      email: extra[:email],
      uid: access_token[:uid],
      provider: access_token[:provider]
    }
  end

  def self.details_from_zooniverse(access_token)
    {
      name: "#{extra[:first_name]} #{extra[:last_name]}",
      email: extra[:email],
      uid: access_token[:uid],
      provider: access_token[:provider]
    }
  end
end
