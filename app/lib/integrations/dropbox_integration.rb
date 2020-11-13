require 'dropbox'

class DropboxIntegration
  FILE_READ_CHUNK_SIZE_BYTES = 512_000

  def initialize(params = {})
    @token = params[:authorization]
  end

  def type
    return "oauth"
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
    Rails.logger.info 'Saving file to Dropbox'

    payload = { items: [params[:item]] }
    payload['auth_params'] = params[:auth_params]

    tmp_file = Tempfile.new(SecureRandom.hex)
    tmp_file.write(JSON.pretty_generate(payload.as_json))
    tmp_file.rewind

    dropbox_upload_session_cursor = dropbox.start_upload_session('')

    File.open(tmp_file.path) do |file|
      dropbox.append_upload_session(
        dropbox_upload_session_cursor,
        file.read(FILE_READ_CHUNK_SIZE_BYTES)
      ) until file.eof?
    end

    metadata = dropbox.finish_upload_session(
      dropbox_upload_session_cursor,
      "/#{params[:name]}",
      '',
      mode: 'overwrite'
    )

    tmp_file.close
    tmp_file.unlink

    { file_path: metadata.path_lower }
  end

  def download_item(metadata)
    file, body = dropbox.download("#{metadata[:file_path]}")
    return body.to_s, file.name
  end

  def delete_item(metadata)
    dropbox.delete(metadata[:file_path])
  end

  private

  def dropbox
    return @dropbox if @dropbox

    @dropbox = Dropbox::Client.new(@token)
  end

  def get_access_key(auth_code, redirect)
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
