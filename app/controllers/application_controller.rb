class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  before_action :set_raven_context

  def index
    @dropbox_link = "/integrations/link?source=dropbox"
    @google_drive_link = "/integrations/link?source=google_drive"
    @webdav_link = "/integrations/link?source=webdav"
  end

  private

  def set_raven_context
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end

end
