class ApplicationController < ActionController::Base
  protect_from_forgery

  @revision = `cat REVISION`
end
