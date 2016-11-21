class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :photo

  validates :user, :presence => true
  validates :photo, :presence => true
  validates :body, :presence => true
end
