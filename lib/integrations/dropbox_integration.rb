class DropboxIntegration

  def initialize(params = {})
    @token = params[:authorization]
  end

  def authorization_link(redirect_url)
    endpoint = "https://www.dropbox.com/1/oauth2/authorize"
    params = "client_id=#{ENV["DROPBOX_CLIENT_ID"]}&response_type=code&redirect_uri=" + redirect_url
    return "#{endpoint}?#{params}"
  end

  def finalize_authorization(params, redirect_url)
    code = params[:code]

    result = get_access_key(code, redirect_url)
    if result[:error]
      return {:error => result[:error]}
    else
      return result[:token]
    end
  end

  def save_item(params)
    payload = { "items" => [params[:item]] }
    payload["auth_params"] = params[:auth_params]
    metadata = dropbox.upload("/#{params[:name]}", "#{JSON.pretty_generate(payload.as_json)}", {:mode => "overwrite"})
    return {:file_path => metadata.path_lower}
  end

  def download_item(metadata)
    file, body = dropbox.download("#{metadata[:file_path]}")
    return body.to_s, file.name
  end

  def delete_item(metadata)
    begin
      dropbox.delete("#{metadata[:file_path]}")
    rescue Exception => e
      puts "Unable to delete Dropbox file because #{e}"
    end
  end

  private

  def dropbox
    if @dropbox
      return @dropbox
    end

    require 'dropbox'
    @dropbox = Dropbox::Client.new(@token)
  end

  def get_access_key(auth_code, redirect)
    require 'dropbox'

    url = "https://api.dropboxapi.com/1/oauth2/token"
    request_params = {
      :code => auth_code,
      :grant_type => "authorization_code",
      :client_id => ENV["DROPBOX_CLIENT_ID"],
      :client_secret => ENV["DROPBOX_CLIENT_SECRET"],
      :redirect_uri => "#{redirect}"
      }

    resp = HTTP.headers(content_type: 'application/json').post(url, :params => request_params)

    if resp.code != 200
      @error = "Unable to authenticate. Please try again."
      return {:error => @error}
    else
      data = JSON.parse(resp.to_s)
      dropbox_token = data["access_token"]
      return {:token => dropbox_token}
    end
  end

end
