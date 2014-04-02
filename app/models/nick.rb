class Nick < ActiveRecord::
  has_many :nick_hostnames
  has_many :hostnames, :through => :nick_hostnames
  has_many :messages
end
