require 'net/sftp'

module SftpHelpers

  HOST = ENV['SFTP_HOST']
  USER = ENV['SFTP_USER']
  PASS = ENV['SFTP_PASS']

  CLAIM_MD_HOST = ENV['CLAIM_MD_SFTP_HOST']
  CLAIM_MD_USER = ENV['CLAIM_MD_SFTP_USER']
  CLAIM_MD_PASS = ENV['CLAIM_MD_SFTP_PASS']

  def sftp_upload(src_path, dst_path = nil, claim_md: false)
    dst_path ||= Pathname.new("/").join(File.basename(src_path))

    sftp_connect(claim_md: claim_md) do |ftp|
      ftp.upload! src_path.to_s, dst_path.to_s
      Rails.logger.info "SFTP(#{HOST}): uploaded #{src_path} to #{dst_path} ..." 
    end
  end

  def sftp_connect(claim_md: false)
    raise ArgumentError unless block_given?

    host = HOST
    user = USER
    pass = PASS

    if claim_md
      host = CLAIM_MD_HOST
      user = CLAIM_MD_USER
      pass = CLAIM_MD_PASS
    end

    Net::SFTP.start(host, user, auth_methods: %w(password), non_interactive: true, password: pass){|ftp| yield(ftp) }
  end

  def sftp_test
    require 'tempfile'

    sftp_connect do |ftp|
      time = Time.now.to_i
      src_file = Tempfile.open("src_sftp_test~#{time}"){|f| f.write("TEST LAH"); f }
      dst_file = Tempfile.new("dst_sftp_test~#{time}")

      ftp.upload! src_file.path, remote_file = "/test_lah"
      ftp.download! remote_file, dst_file.path
      ftp.remove! remote_file

      puts [
        :PASS_TEST,
        [src_file, dst_file].map{|f| File.read(f.path) }.uniq.size == 1
      ].join(" ... ")
    end
  end
  
end
