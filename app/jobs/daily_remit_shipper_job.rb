class DailyRemitShipperJob < ApplicationJob
  queue_as :default

  def perform(*args)
    return unless ENV['SHIP_REMITS'] == '1' && ENV['REMIT_UNSHIPPED_EMAIL']

    Adm::Remit.shippable.unshipped.group_by(&:provider_id).each do |pro_id, remits|
      if provider = remits.first.provider
        if ship_remits(provider.user.email, create_attachments(remits))
          Adm::Remit.where(id: remits.pluck(:id)).update_all(shipped: true)
        end
      else
        # TODO notify admin about invalid provider id
      end
    end

    unshippables = Adm::Remit.unshippable.unshipped
    if unshippables.count > 0
      attachments = create_attachments(unshippables, 'UNSHIPPED-report')
      if ship_remits(ENV['REMIT_UNSHIPPED_EMAIL'], attachments, false)
        unshippables.update_all(shipped: true)
      end
    end
  end

  def ship_remits(email, attachments, bcc=true)
    EncryptedMailer.mail do |m|
      m.to = email
      m.bcc = ENV['REMIT_UNSHIPPED_EMAIL'] if bcc && ENV['REMIT_BCC_EMAIL'] == '1'
      m.subject = "[GeriPSY] Daily EOB Report - #{Date.today}"
      m.body = "Attached"
      attachments.each {|f| m.attach(f)}
    end
  end

  def create_attachments(remits, filename='eob-report')
    remits.map do |remit|
      {
        string: remit.content.gsub("\n", "\r\n"),
        filename: "#{filename}-#{remit.posted_on.to_date}",
        filetype: ".txt"
      }
    end
  end
end

