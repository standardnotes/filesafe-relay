class IntegrationsController < ApplicationController

  # http://localhost:3020/integrations/link?integration=dropbox

  def link
    integration_name = params[:source]
    session[:source] = integration_name

    integration = DropboxIntegration.new
    url = integration.authorization_link(auth_redirect_url)
    redirect_to url
  end

  def save_item
    integration_name = params[:source]
    if integration_name == "dropbox"
      integration = DropboxIntegration.new(:authorization => params[:authorization])
    end

    metadata = integration.save_item({
      name: params[:file][:name],
      item: params[:file][:item],
      auth_params: params[:file][:auth_params],
    })

    metadata[:source] = integration_name

    render :json => {:metadata => metadata}
  end

  def download_item
    metadata = params[:metadata]
    integration_name = metadata[:source]
    if integration_name == "dropbox"
      integration = DropboxIntegration.new(:authorization => params[:authorization])
    end

    body, file_name = integration.download_file(metadata)
    send_data body, filename: file_name
  end

  def oauth_redirect
    @integration_name = session[:source]
    if @integration_name == "dropbox"
      integration = DropboxIntegration.new
    end

    @authorization = integration.finalize_authorization(params, auth_redirect_url)
    redirect_to controller: "integrations", action: 'integration_complete', authorization: @authorization, source: @integration_name
  end

  def integration_complete
    @authorization = params[:authorization]
    @source = params[:source]

    integration = {
      source: @source,
      authorization: @authorization
    }

    @code = Base64.encode64(integration.to_json)
  end

  private

  def auth_redirect_url
    "#{ENV['HOST']}/integrations/oauth-redirect"
  end

end
