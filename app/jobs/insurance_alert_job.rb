class InsuranceAlertJob < ApplicationJob
  def perform(id)
    patient = Pat::Patient.find(id)
    client = Sendinc::Client.new ENV['SENDINC_EMAIL'], ENV['SENDINC_PW']
    client.mail do |msg|
      msg.subject = "[GeriPSY] Patient missing insurance provider"
      msg.to = ENV['INSURANCE_CONTACT_EMAIL']
      msg.body = <<-EOM
Patient Name: #{patient.full_name}
Patient ID: #{patient.id}
      EOM
    end
  end
end
