class DownloadEraFromClaimMdJob < ApplicationJob
  queue_as :hp_billing

  include SftpHelpers

  RECEIVE_FILES_FOLDER = 'ReceiveFiles'

  DIR = Rails.root.join("tmp/eras")

  FILENAME_REGEX = /(.*)_(.*)_(.*)\.pdf/i

  def perform
    # download files
    FileUtils.mkdir_p DIR
    sftp_connect(claim_md: true) do |ftp|
      ftp.dir.foreach(RECEIVE_FILES_FOLDER) do |file|
        remote_path = File.join(RECEIVE_FILES_FOLDER, file.name)
        local_path = File.join(DIR, file.name)

        ftp.download!(remote_path, local_path)
        ftp.remove!(remote_path)
      end
    end

    # associate each local file with a provider tax number based on filename
    provider_map = {}
    unmatched_pdfs = []
    Dir.glob(DIR.join('*.pdf')) do |filename|
      if m = FILENAME_REGEX.match(File.basename(filename))
        provider_map[m[2]] ||= []
        provider_map[m[2]] << filename
      else
        unmatched_pdfs << filename
      end
    end

    if unmatched_pdfs.any?
      attachments = []
      unmatched_pdfs.each do |file|
        attachments << {
          path: file,
        }
      end

      EncryptedMailer.mail do |m|
        m.to = ENV['DEBUG_EMAIL']
        m.subject = "[GeriPSY] Daily EOB Report Bad Filename - #{Date.today}"
        m.body = 'Attached'
        attachments.each { |f| m.attach(f) }
      end
    end

    # send files to providers
    provider_map.each do |npi, files|
      next if files.blank?

      provider = Usr::Provider.where(npi: npi).first
      next if provider.blank?

      attachments = []
      files.each do |file|
        attachments << {
          path: file,
        }
      end

      if provider.nil?
        EncryptedMailer.mail do |m|
          m.to = ENV['DEBUG_EMAIL']
          m.subject = "[GeriPSY] Daily EOB Report Not Delivered - #{Date.today}"
          m.body = 'Attached'
          attachments.each { |f| m.attach(f) }
        end
        next
      end

      EncryptedMailer.mail do |m|
        m.to = provider.user&.email
        m.bcc = [ENV['ADMIN_EMAIL'], ENV['DEBUG_EMAIL']].join(',')
        m.subject = "[GeriPSY] Daily EOB Report - #{Date.today}"
        m.body = 'Attached'
        attachments.each { |f| m.attach(f) }
      end
    end

    # file cleanup
    FileUtils.rm_rf(DIR)
    FileUtils.mkdir_p(DIR)
  end

end
