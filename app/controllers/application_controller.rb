# This is the base controller of the entire application.
# Controller behaviors that are appliction wide are handled here.
class ApplicationController < ActionController::Base
  protect_from_forgery
  before_action :set_revision

  private

  def set_revision
    logger.debug 'Getting revision number'
    
    if File.exist?('REVISION')
      @revision_number = `cat REVISION`
    else
      @revision_number = 'NotDeployed'
    end

    logger.debug 'revisionNumber is: ' + @revisionNumber.to_s
  end
end
