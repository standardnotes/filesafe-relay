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
      return params[:metadata][:source]
    elsif params[:source] || session[:source]
      return params[:source] || session[:source]
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
    metadata = @integration.save_item({
      name: params[:file][:name],
      item: params[:file][:item],
      auth_params: params[:file][:auth_params],
    })

    metadata[:source] = get_integration_name_from_params()

    if !metadata[:error_message].nil?
      response = {:error => {:message => metadata[:error_message]}}
      render :json => response, :status => :bad_request and return
    end

    render :json => {:metadata => metadata}
  end

  def download_item
    metadata = params[:metadata]
    body, file_name, error_message = @integration.download_item(metadata)

    if !error_message.nil?
      response = {:error => {:message => error_message}}
      render :json => response, :status => :bad_request and return
    end

    send_data body, filename: file_name
  end

  def delete_item
    metadata = params[:metadata]
    error_message = @integration.delete_item(metadata)

    if !error_message.nil?
      response = {:error => {:message => error_message}}
      render :json => response, :status => :bad_request and return
    end

    head :no_content
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
    rescue Exception => e
      @error = e
      puts "Oauth Redirect exception: #{e}"
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
