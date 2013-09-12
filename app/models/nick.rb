class Nick < ActiveRecord::Base
  attr_accessible :name, :username
  
  has_many :nick_hostnames
  has_many :hostnames, :through => :nick_hostnames
  has_many :messages
end
