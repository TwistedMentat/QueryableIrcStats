class NickHostname < ActiveRecord::Base
  attr_accessible :hostname_id, :nick_id
  
  belongs_to :hostname
  belongs_to :nick
end
