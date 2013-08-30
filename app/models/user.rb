class User < ActiveRecord::Base
  class_attribute :twitter_user

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable
  validates_presence_of :username
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  attr_accessible :nickname, :provider, :url, :username, :token, :token_secret
  has_many :posts
  has_many :relationships, foreign_key: "follower_id", dependent: :destroy
  has_many :followed_users, through: :relationships, source: :followed
  has_many :reverse_relationships, foreign_key: "followed_id",
           class_name:  "Relationship",
           dependent:   :destroy
  has_many :followers, through: :reverse_relationships, source: :follower


  OPTIONS = {site: "http://api.twitter.com", request_endpoint: "http://api.twitter.com"}

  def self.find_for_twitter_oauth(access_token, signed_in_resource=nil)
    self.twitter_user = access_token
    data = access_token.extra.raw_info

    if user = User.where(username: data.screen_name).first
      user
    else # Create a user with a stub password.
      User.create!(nickname: data.name,
                   username: data.screen_name,
                   provider: access_token.provider,
                   email: "#{data.id}@twitter.com",
                   #token: access_token.credentials.token,
                   #token_secret: access_token.credentials.secret,
                   password: Devise.friendly_token[0,20])
    end
  end

  def post_tweets(message)
    Twitter.configure do |config|
      config.consumer_key = TWITTER_KEY
      config.consumer_secret = TWITTER_SECRET
      config.oauth_token = self.class.twitter_user.credentials.token
      config.oauth_token_secret = self.class.twitter_user.credentials.secret
    end
    client = Twitter::Client.new
    begin
      client.update(message)
      return true
    rescue Exception => e
      self.errors.add(:oauth_token, "Unable to send to twitter: #{e.to_s}")
      return false
    end
  end

  def self.find_for_facebook_oauth access_token
    if user = User.where(:url => access_token.info.urls.Facebook).first
      user
    else
      User.create!(:provider => access_token.provider, :url => access_token.info.urls.Facebook, :username => access_token.extra.raw_info.name, :nickname => access_token.extra.raw_info.username, :email => access_token.extra.raw_info.email, :password => Devise.friendly_token[0,20])
    end
  end

  def following?(other_user)
    relationships.find_by_followed_id(other_user.id)
  end

  def follow!(other_user)
    relationships.create!(followed_id: other_user.id)
  end

  def unfollow!(other_user)
    relationships.find_by_followed_id(other_user.id).destroy
  end
end
