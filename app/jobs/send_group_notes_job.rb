class SendGroupNotesJob < ApplicationJob
  queue_as :default

  def perform(group_encounter_id)
    group_enc = Grp::Encounter.find(group_encounter_id)
    group = group_enc.group
    return unless group_enc.signed? && group.contact_active? && group.contact_email

    user = group.practice.admin.user

    if (encounters = group_enc.session_encounters).present?
      subject = "[GeriPSY] Group Therapy Session Completed"
      msg = {
        'Group' => group.name,
        'Date' => group_enc.service_date.to_date,
        'Provider' => group_enc.signer.full_name
      }.map {|title, val| "<p><strong>#{title}</strong> <span>#{val}</span></p>"}.join

      pdf = PdfGenerator::Encounter.generate(encounters, user: user, type: 'full')

      EncryptedMailer.mail({
        to: group.contact_email,
        subject: subject,
        body: msg,
        attachments: [{
          string: pdf.render,
          filename: group_enc.pdfname,
          filetype: '.pdf'
        }]
      })
    end
  end
end
