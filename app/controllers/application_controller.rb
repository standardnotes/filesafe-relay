class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  def index
    @dropbox_link = "/integrations/link?source=dropbox"
  end
end
