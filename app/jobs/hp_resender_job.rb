class HpResenderJob < ApplicationJob
  queue_as :hp_daily_shipper

  BASE_DATE = "2017-02-01"

  def perform(*args)
    return unless ENV['SHIP_BILLING_TO_HP'] == 'true'
    ids = Enc::Encounter.signed.where(shipped_hp_billing: nil).service_date_between(BASE_DATE, Date.today.to_s).pluck(:id)
    encounters = Enc::Encounter.includes(:signer, {
      patient: [:facility, :primary_insurance, :secondary_insurance, :tertiary_insurance]
    }).signed.where(id: ids).map {|enc|
      enc if enc.valid_for_charge?
    }.compact

    hp_encounters = []
    claim_md_encounters = []
    encounters.each.with_index {|enc,i|
      # skip claims from a provider with a hold
      next if enc.signer&.hold_claims?

      claim_md_encounters << enc
    }

    ShipBillingToClaimMdJob.perform_later(claim_md_encounters.map(&:id)) if claim_md_encounters.any?

    if hp_encounters.present? and ENV['DEBUG_EMAIL']
      msg = {
        'Encounters Sent' => hp_encounters.count,
        'IDs' => hp_encounters.map(&:id).join(', ')
      }.map {|title, val| "<p><strong>#{title}:</strong> <span>#{val}</span></p>"}.join

      EncryptedMailer.mail do |m|
        m.to = ENV['DEBUG_EMAIL']
        m.subject = "[GeriPSY] HP Daily Resend List for #{Date.today}"
        m.body = msg
      end
    end

    if claim_md_encounters.present? and ENV['DEBUG_EMAIL']
      msg = {
        'Encounters Sent' => claim_md_encounters.count,
        'IDs' => claim_md_encounters.map(&:id).join(', ')
      }.map {|title, val| "<p><strong>#{title}:</strong> <span>#{val}</span></p>"}.join

      EncryptedMailer.mail do |m|
        m.to = ENV['DEBUG_EMAIL']
        m.subject = "[GeriPSY] Claim MD Daily Resend List for #{Date.today}"
        m.body = msg
      end
    end
  end
end

