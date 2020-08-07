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
    payload = { "items" => [params[:item]] }
    payload["auth_params"] = params[:auth_params]

    file_path = "#{params[:name]}"
    dir = @auth_params["dir"]
    if dir && dir.length > 0
      file_path = "#{dir}/#{params[:name]}"
    end

    file_path = URI::encode(file_path)

    begin
      self.dav.put_string(file_path, JSON.pretty_generate(payload.as_json))
    rescue Exception => e
      @error_msg = e.message
    end

    return {:file_path => file_path, :error_message => @error_msg}
  end

  def download_item(metadata = {})
    body = nil, filename = nil

    begin
      self.dav.find(metadata[:file_path]) do |item|
        body = item.content
        filename = metadata[:file_path]
      end
    rescue Exception => e
      @error_msg = e.message
    end

    return body, filename, @error_msg
  end

  def delete_item(metadata)
    begin
      self.dav.delete(metadata[:file_path])
    rescue Exception => e
      @error_msg = e.message
    end

    return @error_msg
  end

  def dav
    return @dav if @dav
    @dav = Net::DAV.new(@auth_params["server"])
    @dav.verify_server = false
    @dav.credentials(@auth_params["username"], @auth_params["password"])
    return @dav
  end

end
