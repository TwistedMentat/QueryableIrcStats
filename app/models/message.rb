class Message < ActiveRecord::Base
  attr_accessible :message, :said_at, :action, :nick_id

  belongs_to :nick

  self.per_page = 1000
end
