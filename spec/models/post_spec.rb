require "spec_helper"

describe Post do

  it { should belong_to :user }

  it 'title will be present and body length in 1..254' do
    FactoryGirl.build(:post, body: "a"*255).should_not be_valid
    FactoryGirl.build(:post, body: "").should_not be_valid
    FactoryGirl.build(:post, title: "").should_not be_valid
    FactoryGirl.build(:post).should be_valid
  end

  it "returns a CEO link as a string" do
    post = FactoryGirl.create(:post)
    post.to_param.should == "#{post.id}-#{post.title.parameterize}"
  end

end