class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  before_action :set_raven_context

  def index
    @dropbox_link = "/integrations/link?source=dropbox"
    @google_drive_link = "/integrations/link?source=google_drive"
    @webdav_link = "/integrations/link?source=webdav"
    @aws_s3_link = "/integrations/link?source=AWS_S3"
  end

  def route_not_found
    render :json => {:error => {:message => "Not found."}}, :status => 404
  end

  private

  def set_raven_context
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end

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
