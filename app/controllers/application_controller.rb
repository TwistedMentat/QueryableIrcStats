class ApplicationController < ActionController::Base
  protect_from_forgery
  before_action :set_revision

  private

  def set_revision
    logger.debug 'Getting revision number'
    @revision_number = `cat REVISION`
    logger.debug 'revisionNumber is: ' + @revisionNumber
  end
end
