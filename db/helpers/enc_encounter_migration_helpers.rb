module EncEncounterMigrationHelpers
  class << self

    def fix_dates!
      limit, offset = 1000, 0

      loop do
        processed = 0

        Enc::Encounter.select(:id, :encounter_data, :signed_on).offset(offset).limit(limit).each do |enc|
          processed += 1

          enc.send :ensure_dates_utc_midnight, midnight_tz: "US/Eastern"
          enc.send :capture_certification_timings

          enc.save!
        end

        break if processed.zero?
        offset += limit
      end
    end

    def populate_data_fields!
      fields = Enc::Encounter::DATA_FIELDS
      conds = fields.map{|f| "(#{f} IS NULL)" }.join(" OR ")

      Enc::Encounter.where(conds).find_each(batch_size:500) do |enc|
        enc_data = Hashie::Mash.new(enc.encounter_data)

        values = Hash[fields.map{|f|
          m =  f.to_s =~ /^tp_(.+)$/ ? $1 : f
          data = enc_data[m]
          [f, data.blank? ? {BLANK: true} : data.to_h]
        }].merge(updated_at: Time.now)

        Enc::Encounter.where(id: enc.id).update_all(values)
      end
    end

  end
end
