class Message < ActiveRecord::Base
  attr_accessible :message, :nick, :said_at, :action

  self.per_page = 1000
end
