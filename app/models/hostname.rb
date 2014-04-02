class Hostname < ActiveRecord::Base
  has_many :nick_hostnames
  has_many :nicks, :through => :nick_hostnames
end
