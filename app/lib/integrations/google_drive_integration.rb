class GoogleDriveIntegration

  require 'google/apis/drive_v3'
  require 'google/api_client/client_secrets'

  def initialize(params = {})
    @token = params[:authorization]
  end

  def type
    return "oauth"
  end

  def authorization_link(redirect_url)
    client_secrets = Google::APIClient::ClientSecrets.load
    _auth_client = client_secrets.to_authorization
    _auth_client.update!(
      :scope => 'https://www.googleapis.com/auth/drive.file',
      :redirect_uri => redirect_url
    )

    return _auth_client.authorization_uri.to_s
  end

  def finalize_authorization(params, redirect_url)
    auth_code = params[:code]
    client_secrets = Google::APIClient::ClientSecrets.load
    auth_client = client_secrets.to_authorization
    auth_client.update!(
      :scope => 'https://www.googleapis.com/auth/drive.file',
      :redirect_uri => redirect_url
    )
    auth_client.code = auth_code

    begin
      auth_client.fetch_access_token!
      secret_hash = auth_client.as_json.slice("expiry", "refresh_token", "access_token")
      if secret_hash["refresh_token"] == nil
        return {:error => {:message => 'You have already authorized this application. In order to re-configure, go to <a href="https://myaccount.google.com/permissions">https://myaccount.google.com/permissions</a> and revoke access to "Standard Notes".'}}
      else
        secret_hash[:expires_at] = auth_client.expires_at
        secret_base64 = Base64.encode64(secret_hash.to_json)
        return secret_base64
      end
    rescue Exception => e
      return {:error => {:message => e.message}}
    end
  end

  def find_or_create_folder(folder_name)
    folder_mime = "application/vnd.google-apps.folder"
    folder_search = nil
    begin
      folder_search = drive.list_files(q: "mimeType='#{folder_mime}' and name='#{folder_name}'")
    rescue Exception => e
      puts "\n\n find_or_create_folder exception: #{e}\n\n"
      return
    end

    if folder_search.files.length > 0
      folder = folder_search.files[0]
    else
      folder_data = {
        name: folder_name,
        mime_type: folder_mime
      }
      folder = drive.create_file(folder_data, fields: 'id')
    end

    return folder
  end

  def save_item(params)
    payload = { "items" => [params[:item]] }
    payload["auth_params"] = params[:auth_params]

    begin
      tmp = Tempfile.new(SecureRandom.hex)
      tmp.write("#{JSON.pretty_generate(payload.as_json)}")
      tmp.rewind

      folder = find_or_create_folder("FileSafe")

      file = drive.create_file({:name => params[:name], :parents => [folder.id]}, upload_source: tmp.path, content_type: "application/json")
      puts "Saved file to GD: #{file}"
    rescue Exception => e
      @error_msg = e.message
    end

    return {:file_id => file.id, :error_message => @error_msg}
  end

  def download_item(metadata)
    file_id = metadata[:file_id]
    path = "/tmp/gdrive-tmp-#{file_id}"

    begin
      # Actually download file
      drive.get_file("#{file_id}", download_dest: path)
      body = File.read(path)
      # Get metadata
      file = drive.get_file("#{file_id}")
    rescue Exception => e
      @error_msg = e.message
    end

    return body, file.name, @error_msg
  end

  def delete_item(metadata)
    begin
      file_id = metadata[:file_id]
      drive.delete_file("#{file_id}")
    rescue Exception => e
      puts "Unable to delete Google Drive file because #{e}"
      @error_msg = e.message
    end

    return @error_msg
  end

  private

  def drive
    return @drive if @drive

    client_secrets = Google::APIClient::ClientSecrets.load
    client_params = client_secrets.to_authorization.as_json
    secret_hash = JSON.parse(Base64.decode64(@token))
    client_params.merge!(secret_hash)
    auth_client = Signet::OAuth2::Client.new(client_params)

    @drive = Google::Apis::DriveV3::DriveService.new
    @drive.authorization = auth_client

    return @drive
  end

end
