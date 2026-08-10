class ShipBillingToClaimMdJob < ApplicationJob
  queue_as :hp_billing

  include SftpHelpers

  SEND_FILES_FOLDER = 'SendFiles'

  DIR = Rails.root.join("tmp/billings")
  FileUtils.mkdir_p DIR

  rescue_from(StandardError) do |error|
    backtrace_cleaner = JobCleaner.new

    backtrace_string = backtrace_cleaner.clean(error.backtrace)
    backtrace_string = backtrace_cleaner.clean(error.backtrace, kind: :filter) if backtrace_string.blank?

    body = "<p><strong>#{error.class}</strong>: #{error.message}</p><p><pre>#{backtrace_string.join("\n")}</pre></p>"

    EncryptedMailer.mail do |m|
      m.to = ENV['DEBUG_EMAIL']
      m.subject = "[GeriPSY] Claim MD Shipping Error - #{Date.today}"
      m.body = body
    end
  end

  def perform(ids)
    encounters = Enc::Encounter.where(id: ids).includes(:signer, {
      patient: [:facility, :primary_insurance, :secondary_insurance, :tertiary_insurance]
    })

    ship_notes(encounters)
  end

  def ship_notes(encounters, builder=nil)
    ActiveRecord::Base.transaction do
      encounters_to_ship = []
      encounters.each do |encounter|
        if encounter.shipped_to_claim_md?
          warn "Skipping encounter #{encounter.id} - already shipped"
          next
        end

        encounter.build_claim_md_xml!(builder)
        encounters_to_ship << encounter
      end

      # TODO: send in batches of 1000?
      path = DIR.join("claim_md_#{Time.now.to_i}.xml")
      File.open(path, 'w') do |f|
        f.write('<claims>')
        encounters.each do |encounter|
          if !encounter.valid_for_charge?
            warn "Skipping encounter #{encounter.id} - not valid for charge"
            next
          end

          if encounter.shipped_hp_billing['xml'].present?
            xml = encounter.shipped_hp_billing['xml']
            xml.sub!(/^<claims>/i, '')
            xml.chomp!('</claims>')
            f.write(xml)
          end
        end
        f.write('</claims>')
      end
      sftp_upload(path, SEND_FILES_FOLDER, claim_md: true)
    end
  end

end
