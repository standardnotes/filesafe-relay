require 'aws-sdk-s3'

class S3Integration
  def initialize(params = {})
    if params[:authorization]
      @auth_params = JSON.parse(Base64.decode64(params[:authorization]))
    end
  end

  def type
    return "form"
  end

  def save_item(params)
    Rails.logger.info 'Saving file to S3'

    payload = { items: [params[:item]] }
    payload['auth_params'] = params[:auth_params]

    obj_key = "FileSafe/#{params[:name]}"

    bucket.object(obj_key).put(body: JSON.pretty_generate(payload.as_json))

    { obj_key: obj_key }
  end

  def download_item(metadata = {})
    file = bucket.object(metadata[:obj_key]).get
    return file.body.string, metadata[:obj_key]
  end

  def delete_item(metadata)
    bucket.object(metadata[:obj_key]).delete
  end

  def bucket
    ep = ""
    case @auth_params["endpoint"]
    when "SCW"
      ep = "https://s3.%s.scw.cloud" % [@auth_params["region"]]
    when "BB2"
      ep = "https://s3.%s.backblazeb2.com" % [@auth_params["region"]]
    end

    @bucket ||= begin
      s3 = Aws::S3::Resource.new({
        endpoint: ep,
        region: @auth_params["region"],
        credentials: Aws::Credentials.new(@auth_params["key"], @auth_params["secret"])
      })
      s3.bucket(@auth_params["bucket"])
    end
  end
end
