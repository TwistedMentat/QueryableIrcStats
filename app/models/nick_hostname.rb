# Bridging class between nicks and hostnames.
class NickHostname < ActiveRecord::Base
  belongs_to :hostname
  belongs_to :nick
end
