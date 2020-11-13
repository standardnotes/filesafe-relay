class WebdavIntegration
  require 'net/dav'

  def initialize(params = {})
    if params[:authorization]
      @auth_params = JSON.parse(Base64.decode64(params[:authorization]))
    end
  end

  def type
    return "form"
  end

  def save_item(params)
    Rails.logger.info 'Saving file to WebDAV'

    payload = { items: [params[:item]] }
    payload['auth_params'] = params[:auth_params]

    file_path = params[:name]
    dir = @auth_params['dir']
    file_path = "#{dir}/#{params[:name]}" if dir&.length&.positive?

    file_path = URI::encode(file_path)
    dav.put_string(file_path, JSON.pretty_generate(payload.as_json))

    { file_path: file_path }
  end

  def download_item(metadata = {})
    body = nil, filename = nil
    self.dav.find(metadata[:file_path]) do |item|
      body = item.content
      filename = metadata[:file_path]
    end

    return body, filename
  end

  def delete_item(metadata)
    self.dav.delete(metadata[:file_path])
  end

  def dav
    return @dav if @dav
    @dav = Net::DAV.new(@auth_params["server"])
    @dav.verify_server = false
    @dav.credentials(@auth_params["username"], @auth_params["password"])
    return @dav
  end

end
