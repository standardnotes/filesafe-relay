class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  def index
    @dropbox_link = "/integrations/link?source=dropbox"
    @google_drive_link = "/integrations/link?source=google_drive"
  end

end
