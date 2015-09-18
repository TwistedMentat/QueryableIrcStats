# Represents users in the application. 
# Users can be added to the uploaders group to upload new log files.
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  # attr_accessible :email, :password, :password_confirmation, :remember_me
  # attr_accessible :title, :body

  belongs_to :group

  def can_upload_log?
    if group.name == 'log_uploader'
      return true
    else
      return false
    end
  end
end
