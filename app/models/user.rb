class User < ActiveRecord::Base

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable
  validates_presence_of :username
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  attr_accessible :nickname, :provider, :url, :username, :token, :token_secret
  has_many :posts

  #CONSUMER_KEY = 'WHAT_IS_YOUR_CONSUMER_KEY'
  #CONSUMER_SECRET = 'WHAT_IS_YOUR_CONSUMER_SECRET'
  #ACCESS_TOKEN = 'WHAT_IS_YOUR_ACCESS_TOKEN'
  #ACCESS_TOKEN_SECRET = 'WHAT_IS_YOUR_ACCESS_TOKEN_SECRET'

  OPTIONS = {site: "http://api.twitter.com", request_endpoint: "http://api.twitter.com"}

  def self.find_for_twitter_oauth(access_token, signed_in_resource=nil)
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
      config.consumer_key = User::CONSUMER_KEY
      config.consumer_secret = User::CONSUMER_SECRET
      config.oauth_token = ACCESS_TOKEN
      config.oauth_token_secret = ACCESS_TOKEN_SECRET
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
end
