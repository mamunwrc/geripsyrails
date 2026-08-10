namespace :geripsy do
  desc "Daily emailer of signed encounters"
  task daily_mailer: :environment do
    DailyMailerJob.perform_later
  end

  desc "Daily HP resender for files that werent valid for charge previously"
  task hp_resender: :environment do
    HpResenderJob.perform_later
  end

  desc "Daily notifier of patients missing all insurance data"
  task insurance_notifier: :environment do
    DailyInsuranceAlertJob.perform_later
  end

  desc "Daily remit shipper"
  task remit_shipper: :environment do
    DailyRemitShipperJob.perform_later
  end

  desc "Daily EOB/ERA sender"
  task era_sender: :environment do
    DownloadEraFromClaimMdJob.perform_later
  end
end

