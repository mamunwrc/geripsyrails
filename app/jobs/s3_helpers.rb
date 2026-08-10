module S3Helpers

  BUCKET = ENV['AWS_S3_BUCKET']
  REGION = ENV['AWS_S3_REGION']
  ACCESS_KEY_ID = ENV['AWS_S3_ACCESS_KEY_ID']
  SECRET_ACCESS_KEY = ENV['AWS_S3_SECRET_ACCESS_KEY']

  def s3_upload(key, data, **opts)
    s3_bucket(opts) do |bucket|
      object = bucket.put_object({
        key: key,
        body: data,
        server_side_encryption: "AES256",
      })

      OpenStruct.new(
        bucket: bucket.url,
        key: object.key
      )
    end
  end

  def s3_bucket(opts)
    raise ArgumentError unless block_given?

    bucket, region =
      case bucket = opts[:bucket] || BUCKET
      when %r(://)
        uri = URI.parse(bucket)
        dom = PublicSuffix.parse(uri.host)

        [dom.sld, dom.tld.sub(%r(^s3-(.*)\.amazonaws\.com$), '\1')]
      else
        [bucket, opts[:region] || REGION]
      end

    client = Aws::S3::Client.new({
      region: region,
      access_key_id: opts[:access_key_id] || ACCESS_KEY_ID,
      secret_access_key: opts[:secret_access_key] || SECRET_ACCESS_KEY,
    })

    yield(Aws::S3::Bucket.new(client: client, name: bucket))
  end

  def s3_test
    require 'tempfile'

    time = Time.now.to_i
    src_file = Tempfile.open("src_s3_test~#{time}"){|f| f.write("TEST LAH"); f }
    uploaded = s3_upload("geripsy/test/#{File.basename(src_file.path)}", src_file)

    s3_bucket(bucket: uploaded.bucket) do |bucket|
      uploaded_content = bucket.object(uploaded.key).get.body.read

      puts [
        :PASS_TEST,
        [File.read(src_file), uploaded_content].uniq.size == 1
      ]
    end
  end
  
end
