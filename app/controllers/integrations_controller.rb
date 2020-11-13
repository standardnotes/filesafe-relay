class IntegrationsController < ApplicationController
  # http://localhost:3020/integrations/link?source=dropbox

  before_action {
    integration_name = get_integration_name_from_params
    if integration_name
      if integration_name == "dropbox"
        @integration = DropboxIntegration.new(:authorization => params[:authorization])
      elsif integration_name == "google_drive"
        @integration = GoogleDriveIntegration.new(:authorization => params[:authorization])
      elsif integration_name == "webdav"
        @integration = WebdavIntegration.new(:authorization => params[:authorization])
      elsif integration_name === "AWS_S3"
        @integration = AwsS3Integration.new(:authorization => params[:authorization])
      end
    end
  }

  def get_integration_name_from_params
    if params[:metadata]
      params[:metadata][:source]
    elsif params[:source] || session[:source]
      params[:source] || session[:source]
    end
  end

  def link
    integration_name = params[:source]
    session[:source] = integration_name
    if @integration.type == "oauth"
      url = @integration.authorization_link(auth_redirect_url)
      redirect_to url
    elsif @integration.type == "form"
      render action: "form_#{integration_name.downcase}"
    end
  end

  def submit_form
    @code = Base64.encode64(params[:auth_data].to_json)

    redirect_to controller: 'integrations', action: 'integration_complete', authorization: @code, source: get_integration_name_from_params
  end

  def save_item
    metadata = @integration.save_item(
      name: params[:file][:name],
      item: params[:file][:item],
      auth_params: params[:file][:auth_params]
    )

    metadata[:source] = get_integration_name_from_params

    render json: { metadata: metadata }
  rescue StandardError => e
    Rails.logger.error "Could not save item: #{e.message}"

    render(
      json: {
        error: {
          message: 'Could not save item. Please verify your integration.'
        }
      },
      status: :bad_request
    )
  end

  def download_item
    metadata = params[:metadata]
    body, file_name = @integration.download_item(metadata)
    send_data body, filename: file_name
  rescue StandardError => e
    Rails.logger.error "Could not download item: #{e.message}"

    render(
      json: {
        error: {
          message: 'Could not retrieve item. Please verify your integration.'
        }
      },
      status: :bad_request
    )
  end

  def delete_item
    metadata = params[:metadata]
    @integration.delete_item(metadata)
  rescue StandardError => e
    Rails.logger.error "Could not delete item: #{e.message}"

    render(
      json: {
        error: {
          message: 'Could not delete item. Please verify your integration.'
        }
      },
      status: :bad_request
    )
  end

  def oauth_redirect
    @integration_name = session[:source]
    begin
      @authorization = @integration.finalize_authorization(params, auth_redirect_url)
      if @authorization.is_a?(Hash) && @authorization[:error]
        @error = @authorization[:error]
      else
        redirect_to controller: "integrations", action: 'integration_complete', authorization: @authorization, source: @integration_name
      end
    rescue StandardError => e
      @error = e
    end
  end

  def integration_complete
    @authorization = params[:authorization]
    @source = params[:source]

    integration = {
      source: @source,
      authorization: @authorization,
      relayUrl: ENV['HOST']
    }

    # Remove whitespace
    @code = Base64.encode64(integration.to_json).gsub(/[[:space:]]/, '')
  end

  private

  def auth_redirect_url
    "#{ENV['HOST']}/integrations/oauth-redirect"
  end
end
