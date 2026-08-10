class DailyInsuranceAlertJob < ApplicationJob
  queue_as :default

  def perform(*args)
    require 'csv'

    problem_patients =
      Pat::Patient.where.not(primary_insurance_id: [nil, 0]).
        where(primary_insurance_number: [nil, '']).
        or(
          Pat::Patient.where.not(secondary_insurance_id: [nil, 0]).
          where(secondary_insurance_number: [nil, ''])
        ).or(
          Pat::Patient.where.not(tertiary_insurance_id: [nil, 0]).
          where(tertiary_insurance_number: [nil, ''])
        ).map {|patient|
          [
            patient.id,
            patient.full_name,
            patient.primary_insurance.try(:name),
            patient.primary_insurance_number,
            patient.secondary_insurance.try(:name),
            patient.secondary_insurance_number,
            patient.tertiary_insurance.try(:name),
            patient.tertiary_insurance_number
          ]
        }

    return if problem_patients.blank?

    csv_patients = CSV.generate do |csv|
      csv << ["Patient ID", "Name", "Primary Ins", "Primary ID#", "Secondary Ins", "Secondary ID#", "Tertiary Ins", "Tertiary ID#"]
      problem_patients.each do |patient|
        csv << patient
      end
    end

    EncryptedMailer.mail do |msg|
      msg.subject = "[GeriPSY] Patients Missing Insurance Info"
      msg.to      = ENV['INSURANCE_CONTACT_EMAIL']
      msg.body    = "The attached patients have incomplete insurance data"
      msg.attach string: csv_patients, filename: "patients-missing-insurance-#{Date.today}", filetype: '.csv'
    end
  end
end

