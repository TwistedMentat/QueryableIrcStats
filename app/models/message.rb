class Message < ActiveRecord::Base
  belongs_to :nick

  self.per_page = 1000
end
