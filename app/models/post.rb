class Post < ActiveRecord::Base
  attr_accessible :body, :title, :user_id
  belongs_to :user

  validates :body, :length => { :in => 1..254 }, :allow_blank => false
  validates :title, :presence => true

  def to_param
    "#{id}-#{title.parameterize}"
  end
end
