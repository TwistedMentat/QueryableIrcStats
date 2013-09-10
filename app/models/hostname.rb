class Hostname < ActiveRecord::Base
  attr_accessible :domain_name
  
  has_many :nick_hostnames
  has_many :nicks, :through => :nick_hostnames
end
