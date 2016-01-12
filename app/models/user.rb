class User 
  include Mongoid::Document
  include Mongoid::Timestamps
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable


  devise :omniauthable, :omniauth_providers => [:facebook,:google_oauth2,:zooniverse]


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
  field :provider,           :type => String    # e.g. 'facebook', 'google_oauth2', 'zooniverse'

  field :avatar,             :type => String    # URI of image if any
  field :profile_url,        :type => String    # URI of user profile, if any
  
  field :status,             :type => String, :default => 'active'
  field :role,               :type => String, :default => 'user'  # user, admin, team, robot
  field :guest,              :type => Boolean, :default => false
  field :tutorial_complete,  :type => Boolean, :default => false

  has_many :favourites
  has_many :classifications

  after_create :apply_configured_user_role

  index({created_at: 1}, {background: true})

  ## Confirmable
  # field :confirmation_token,   :type => String
  # field :confirmed_at,         :type => Time
  # field :confirmation_sent_at, :type => Time
  # field :unconfirmed_email,    :type => String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, :type => Integer, :default => 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    :type => String # Only if unlock strategy is :email or :both
  # field :locked_at,       :type => Time

  def tutorial_complete!
    self.tutorial_complete = true
    self.save!(:validate => false)
  end

  def has_favourite?(subject)
    favourites.where( subject_id: subject.id ).exists?
  end

  def has_classified?(subject)
    subject.classifying_user_ids and subject.classifying_user_ids.include? id
  end

  def recents(limit=10)
    classifications.order_by(created_at: 1).limit(limit)
  end

  def recents_for_workflow(workflow, limit=10)
    recents(limit).where(workflow_id: workflow.id)
  end

  def to_s
    name
  end

  # Steal all the contributions of the given user (e.g. visitor made some 
  # contribs as a guest, then logged in with a real acct and we want to 
  # transfer the guest contribs to the real acct
  def steal_contributions(other_user)
    [:classifications, :favourites].each do |relation|
      rels = other_user.send relation
      rels.each do |rel|
        rel.user = self
        rel.save!
      end
    end
  end

  # Called after_create, assigns role=admin if email matches admin_email in project.json
  # Assigns role=team if email is in team_emails
  def apply_configured_user_role
    # Make admin?
    if email == Project.current.admin_email
      update_attribute :role, 'admin'

    # Make the team?
    elsif Project.current.team_emails.include? email
      update_attribute :role, 'team'
    end
  end

  def can_view_admin?
    admin? || team?
  end

  def team?
    role == 'team'
  end

  def admin?
    role == 'admin'
  end


  def self.find_for_oauth(access_token, signed_in_resource=nil)

    if user = self.find_by({provider: access_token[:provider], uid: access_token[:uid]})
      user
    else # Create a user with a stub password.
      details = details_from_oauth access_token[:provider], access_token
      tmp_pass = Devise.friendly_token[0,20]
      self.create details.merge(password: tmp_pass, password_confirmation: tmp_pass)
    end
  end

  def self.details_from_oauth(provider,access_token)
    case provider.to_s
    when "facebook"
      details_from_fb(access_token)
    when "google","google_oauth2"
      details_from_google(access_token)
    when "zooniverse"
      details_from_zooniverse(access_token)
    end
  end

  def self.details_from_fb(access_token)
    extra = access_token[:extra][:raw_info]
    info = access_token[:info]
    {
      name: extra[:name],
      email: extra[:email],
      uid: access_token[:uid],
      provider: access_token[:provider],
      avatar: info[:image]
    }
  end

  def self.details_from_google(access_token)
    extra = access_token[:extra][:raw_info]
    {
      name: "#{extra[:name]}",
      email: extra[:email],
      uid: access_token[:uid],
      provider: access_token[:provider],
      avatar: extra[:picture],
      profile_url: extra[:profile]
    }
  end

  def self.details_from_zooniverse(access_token)
    info = access_token["info"]
    {
      name: info["name"],
      email: info["email"],
      uid: access_token["uid"],
      provider: access_token["provider"]
    }
  end
  
  def self.create_guest_user
    u = create({
      name: 'Guest',
      guest: true,
      role: 'user'
    })
    u.save!(:validate => false)
    u
  end

  def self.auth_providers
    providers = API::Application.config.auth_providers

    providers.map do |p|
      case p
      when 'facebook'
        { id: p, path: '/users/auth/facebook', name: 'Facebook' }
      when 'google'
        { id: p, path: '/users/auth/google_oauth2', name: 'Google' }
      when 'zooniverse'
        { id: p, path: '/users/auth/zooniverse', name: 'Zooniverse' }
      end
    end
  end

  # Returns hash mapping distinct values for given field to matching count:
  def self.group_by_hour(match={})
    agg = []
    agg << {"$match" => match } if match
    agg << {"$group" => { 
      "_id" => {
        "y" => { '$year' => '$created_at' },
        "m" => { '$month' => '$created_at' },
        "d" => { '$dayOfMonth' => '$created_at' },
        "h" => { '$hour' => '$created_at' }
      },
      "count" => {"$sum" =>  1} 
    }}
    self.collection.aggregate(agg).inject({}) do |h, p|
      h[p["_id"]] = p["count"]
      h
    end
  end

  def self.robot
    @robot_user ||= (
      find_by(role: 'robot')
    )
  end

  def self.bot_user_by_auth(auth)
    user = User.find_or_create_by name: 'Robot', role: 'robot'
    user.save! validate: false
    user
  end

end
