class FacilityMailerJob < ApplicationJob
  queue_as :default

  def perform(facility_id)
    facility = Adm::Facility.find(facility_id)
    return unless facility

    contacts = facility.facility_contacts.active
    return unless contacts.count > 0

    encounters = Enc::Encounter.signed.joins(:patient).
      where("signed_on >= ? and signed_on < ?", Date.yesterday, Date.today).
      where("pat_patients.facility_id = ?", facility.id)

    return if encounters.count.zero?

    generated_files = []

    mails = Hash[[:pdf, :docx].map {|type|
      [type, Hash.new{|h,k| h[k] = []}]
    }].with_indifferent_access
    contacts.inject(mails) do |lists, contact|
      lists.tap do |_lists|
        _lists[contact.export_format][contact.export_type] << contact.email
      end
    end.each do |format, types|
      types.each do |type, emails|
        next if emails.blank?
        path = generate(format, encounters, type: type, facility: facility)
        generated_files << path
        msg_body = {
          'Facility' => facility.name,
          'Encounters signed today' => encounters.count
        }.map {|title, val| "<p><strong>#{title}</strong> <span>#{val}</span></p>"}.join

        send_mail path, msg_body, emails
      end
    end

    cleanup(generated_files)
  end

  private

  def cleanup(files)
    files.each {|path| FileUtils.rm(path) if path && File.file?(path)}
  end

  def generate(format, encounters, opts={})
    send(:"__#{format}_generator__", encounters, opts)
  end

  def send_mail(path, body, emails=[])
    EncryptedMailer.mail do |msg|
      msg.subject = "[GeriPSY] Daily encounter mailer for #{Date.yesterday}"
      msg.to      = ENV['ADMIN_EMAIL']
      msg.bcc     = emails.join(",")
      msg.body    = body
      msg.attach path
    end
  end

  def __pdf_generator__(encounters, opts)
    fac = opts[:facility]
    pdf = PdfGenerator::Encounter.generate(encounters, type: opts[:type], user: fac.practice.admin.user)
    path_for(fac, :pdf, opts[:type]).tap {|path| File.open(path, 'wb') {|f| f.puts pdf.render} }
  end

  def __docx_generator__(encounters, opts)
    fac = opts[:facility]
    path_for(fac, :zip, opts[:type]).tap do |path|
      Zip::OutputStream.open(path) do |zos|
        encounters.each do |encounter|
          zos.put_next_entry encounter.docxname
          zos.puts DocxGenerator::Encounter.generate(encounter, type: opts[:type], user: fac.practice.admin.user).render
        end
      end
    end
  end

  def path_for(facility, format, type=:full)
    "/tmp/encounters-f#{facility.id}-#{Date.yesterday}.#{type}.#{format}"
  end
end

