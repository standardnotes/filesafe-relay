require 'aws-sdk-s3'

class AwsS3Integration
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
    obj_key = "FileSafe/#{params[:name]}"
    
    begin
      bucket.object(obj_key).put(body: JSON.pretty_generate(payload.as_json))
    rescue Exception => e
      @error_msg = e.message
    end

    return {:obj_key => obj_key, :error_message => @error_msg}
  end

  def download_item(metadata = {})
    body = nil, obj_key = nil

    begin
      file = bucket.object(metadata[:obj_key]).get
      body = file.body.string
      obj_key = metadata[:obj_key]
    rescue Exception => e
      @error_msg = e.message
    end

    return body, obj_key, @error_msg
  end

  def delete_item(metadata)
    begin
      bucket.object(metadata[:obj_key]).delete
    rescue Exception => e
      puts "Unable to delete AWS S3 file because #{e}"
      @error_msg = e.message
    end

    return @error_msg
  end

  def bucket
    @bucket ||= begin
      s3 = Aws::S3::Resource.new({
        region: @auth_params["region"],
        credentials: Aws::Credentials.new(@auth_params["key"], @auth_params["secret"])
      })
      s3.bucket(@auth_params["bucket"])
    end
  end
end
