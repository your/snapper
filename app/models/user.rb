class User < ActiveRecord::Base
  has_many :snapshots
  has_many :authorizations
  validates_presence_of :name
  validates_presence_of :locale
  validates_presence_of :timezone
end
