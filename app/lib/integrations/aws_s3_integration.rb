require 'aws-sdk-s3'

class AwsS3Integration
  def initialize(params = {})
    if params[:authorization]
      @auth_params = JSON.parse(Base64.decode64(params[:authorization]))

      Aws.config.update({
        region: @auth_params["region"],
        credentials: Aws::Credentials.new(@auth_params["key"], @auth_params["secret"])
      })
    end
  end

  def type
    return "form"
  end

  def save_item(params)
    payload = { "items" => [params[:item]] }
    payload["auth_params"] = params[:auth_params]
    obj_key = "FileSafe/#{params[:name]}"
    bucket.object(obj_key).put(body: JSON.pretty_generate(payload.as_json))
    return {:obj_key => obj_key}
  end

  def download_item(metadata = {})
    file = bucket.object(metadata[:obj_key]).get
    return file.body.string, metadata[:obj_key]
  end

  def delete_item(metadata)
    begin
      bucket.object(metadata[:obj_key]).delete
    rescue Exception => e
      puts "Unable to delete AWS S3 file because #{e}"
    end
  end

  def bucket
    @bucket ||= begin
      s3 = Aws::S3::Resource.new
      s3.bucket(@auth_params["bucket"])
    end
  end
end
