class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  def index
    @dropbox_link = "/integrations/link?source=dropbox"
    @google_drive_link = "/integrations/link?source=google_drive"
    @webdav_link = "/integrations/link?source=webdav"
    @s3_link = "/integrations/link?source=AWS_S3"
  end

  def route_not_found
    render :json => {:error => {:message => "Not found."}}, :status => 404
  end

  private

  def append_info_to_payload(payload)
    super

    unless payload[:status]
      return
    end

    payload[:level] = 'INFO'
    if payload[:status] >= 500
      payload[:level] = 'ERROR'
    elsif payload[:status] >= 400
      payload[:level] = 'WARN'
    end
  end
end
