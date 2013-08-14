#require 'faker'

OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new({
                                        :provider => 'facebook',
                                        :uid => '100003778509162',
                                        :info => {:email => 'tamag5ochi@ukr.net',
                                                   :urls => {:Facebook=> 'https://www.facebook.com/tama.gochi.73'}},
                                        :extra => {:raw_info => {:name => 'Tama Gochi',
                                                                    :email => 'tamag5ochi@ukr.net'}}})

OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new({
                                       :provider => 'twitter',
                                       :uid => '123545',
                                       :info => { :nickname => 'Joe Blow'},
                                       :extra => {:raw_info => { :id => 1,
                                                                    :name => 'Tama Gochi',
                                                                    :screen_name =>'tamag5ochi',
                                                                    :email => 'tamag5ochi@ukr.net'}}})
FactoryGirl.define do
  factory :user do
    username 'Tama Gochi'
    email "tamag5ochi@ukr.net"
    password "password"
    password_confirmation { password }
  end

  factory :invalid_user, :parent => :user do
    email ""
  end
end