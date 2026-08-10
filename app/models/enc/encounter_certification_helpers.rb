module Enc::EncounterCertificationHelpers
  extend ActiveSupport::Concern

  class_methods do
    def referral_fields(*fields)
      return @__referral_fields__ unless fields.present?
      @__referral_fields__ = fields
    end

    def referral_base(base=nil)
      return @__referral_base__ unless base
      @__referral_base__ = base
    end
  end

  def capture_certification
    tz_offset = certification.tz_offset_mins || (Time.now.in_time_zone("US/Eastern").utc_offset / 60)
    self.signed_on = (DateTime.now + tz_offset.minutes).to_date
    self.signed_by = provider_id

    capture_certification_timings
  end

  def capture_certification_timings
    %i(start_time end_time).each do |f|
      next if (cert = certification).blank?
      raw, timing = extract_raw_and_timing(cert[f], cert.tz_offset_mins)

      if timing
        certification[:"#{f}_raw"] = raw
        certification[f] = timing
      end
    end
  end

  def extract_raw_and_timing(datestring, tz_offset_mins = nil)
    return if datestring.blank?
    return if datestring =~ %r(^\d+:\d+$)

    date = DateTime.parse(datestring)
    time =
      if tz_offset_mins.to_s =~ /^-?\d+$/
        date + tz_offset_mins.to_i.minutes
      else
        date.in_time_zone("US/Eastern")
      end.strftime("%H:%M")

    return [datestring, time.strip]
  end

  def extract_raw_and_date(datestring, **opts)
    return if datestring.blank?
    date = datestring.to_datetime
    return if date == date.utc.midnight

    date =
      if opts[:min_offset]
        (date + opts[:min_offset].minutes).midnight
      elsif opts[:midnight_tz]
        date.in_time_zone(opts[:midnight_tz]).midnight
      else
        date.utc.midnight
      end
    [ datestring, date ]
  end

  def ensure_dates_utc_midnight(**opts)
    unless opts[:skip_referral_dates]
      self.class.referral_fields.each do |f|
        ref_base = send(self.class.referral_base)
        raw, date = extract_raw_and_date(ref_base.try(f), opts)

        if date
          ref_base.send(:"#{f}_raw=", raw)
          ref_base.send(:"#{f}=", date)
        end
      end
    end
  end
end
