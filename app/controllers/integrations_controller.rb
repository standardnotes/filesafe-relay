class IntegrationsController < ApplicationController

  # http://localhost:3020/integrations/link?integration=dropbox

  def link
    integration_name = params[:integration]
    session[:integration] = integration_name

    integration = DropboxIntegration.new
    url = integration.authorization_link(auth_redirect_url)
    redirect_to url
  end

  def save_item
    integration_name = params[:integration]
    if integration_name == "dropbox"
      integration = DropboxIntegration.new(:authorization => params[:authorization])
    end

    metadata = integration.save_item({
      name: params[:file][:name],
      item: params[:file][:item],
      auth_params: params[:file][:auth_params],
    })

    render :json => {:metadata => metadata}
  end

  def download_file
    integration_name = params[:integration]
    if integration_name == "dropbox"
      integration = DropboxIntegration.new(:authorization => params[:authorization])
    end

    integration.download_file(params[:metadata])
  end

  def oauth_redirect
    integration_name = session[:integration]
    if integration_name == "dropbox"
      integration = DropboxIntegration.new
    end

    authorization = integration.finalize_authorization(params, auth_redirect_url)
    render :json => {:authorization => authorization}
  end

  private

  def auth_redirect_url
    "#{ENV['HOST']}/integrations/oauth-redirect"
  end

end
