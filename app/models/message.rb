class Message < ActiveRecord::Base
  attr_accessible :message, :nick, :saidAt
end
