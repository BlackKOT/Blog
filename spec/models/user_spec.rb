require_relative '../spec_helper'

  describe User do
    it { should have_many :posts }
    it { should validate_presence_of(:username) }
    it { should validate_uniqueness_of(:email) }
    it { should validate_presence_of(:email) }
    it { should ensure_length_of(:password).is_at_least(8) }

    describe 'test Facebook user' do

      it 'request existing user' do
        @prev_count = User.count
        User.find_for_facebook_oauth(OmniAuth.config.mock_auth[:facebook])
        @prev_count.should_not eql User.count
      end

      it 'create new user' do
        User.find_for_facebook_oauth(OmniAuth.config.mock_auth[:facebook])
        @prev_count = User.count
        User.find_for_facebook_oauth(OmniAuth.config.mock_auth[:facebook])
        @prev_count.should eql User.count
      end

    end

    describe 'test Twitter user' do

      it 'request existing user' do
        @prev_count = User.count
        User.find_for_twitter_oauth(OmniAuth.config.mock_auth[:twitter])
        @prev_count.should_not eql User.count
      end

      it 'create new user' do
        User.find_for_twitter_oauth(OmniAuth.config.mock_auth[:twitter])
        @prev_count = User.count
        User.find_for_twitter_oauth(OmniAuth.config.mock_auth[:twitter])
        @prev_count.should eql User.count
      end

    end
    #TODO mocha ?
    describe 'test Twitter sending message' do
      it 'repost message on Twitter ' do
        #User.find_for_twitter_oauth(OmniAuth.config.mock_auth[:twitter])
        @twitter = double("Twitter")
        @twitter.stub!(:configure).and_return true
        @client = double("Twitter::Client")
        @client.stub!(:current_user).and_return(@user)
        @user = double("Twitter::User")
        @user.stub!(:post_tweets).and_return(true)
        #user = stubs("user")
        #user.stubs(:post_tweets).returns(true)
        @user.post_tweets("sample tweet").should be_true
      end
    end

  end