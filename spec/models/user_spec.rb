require "spec_helper"

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
  end