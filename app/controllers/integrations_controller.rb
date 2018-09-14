class IntegrationsController < ApplicationController

  # http://localhost:3020/integrations/link?integration=dropbox

  before_action {
    integration_name = get_integration_name_from_params
    if integration_name
      if integration_name == "dropbox"
        @integration = DropboxIntegration.new(:authorization => params[:authorization])
      elsif integration_name == "google_drive"
        @integration = GoogleDriveIntegration.new(:authorization => params[:authorization])
      elsif integration_name == "webdav"
        @integration = WebdavIntegration.new(:authorization => params[:authorization])
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
    else
      # form will be presented as default in link.html
    end
  end

  def submit_form
    auth_params = {
      server: params[:server],
      username: params[:username],
      password: params[:password],
      dir: params[:dir]
    }

    @code = Base64.encode64(auth_params.to_json)

    redirect_to controller: 'integrations', action: 'integration_complete', authorization: @code, source: "webdav"
  end

  def save_item
    metadata = @integration.save_item({
      name: params[:file][:name],
      item: params[:file][:item],
      auth_params: params[:file][:auth_params],
    })

    metadata[:source] = get_integration_name_from_params()

    render :json => {:metadata => metadata}
  end

  def download_item
    metadata = params[:metadata]
    body, file_name = @integration.download_item(metadata)
    send_data body, filename: file_name
  end

  def delete_item
    metadata = params[:metadata]
    @integration.delete_item(metadata)
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
