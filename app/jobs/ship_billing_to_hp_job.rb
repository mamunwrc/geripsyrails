class ShipBillingToHpJob < ApplicationJob
  queue_as :hp_billing

  include SftpHelpers

  DIR = Rails.root.join("tmp/billings")
  FileUtils.mkdir_p DIR

  def perform(id)
    enc = Enc::Encounter.find(id)

    if enc.cpt_encounter_code.in?(Enc::Encounter::TESTING_EVAL_CODES)
      ship_testing_note(enc)
    else
      ship_note(enc)
    end
  end

  def ship_note(enc, builder=nil, nullify=false)
    enc.build_hp_xml!(builder) do |billing|
      path = DIR.join(billing.filename)

      File.open(path,'w'){|f| f.write billing.xml }
      sftp_upload path
    end

    if nullify
      hp_data = enc.shipped_hp_billing.dup
      enc.testing_note_hp_cache["files"] << hp_data
      enc.shipped_hp_billing = nil
      enc.save
      hp_data
    end
  end

  def ship_testing_note(enc)
    ref = enc.referral
    builder = enc.build_hp_xml
    hp_data = ship_note(enc, builder, true)

    if ref.minutes > 90
      mins = ref.minutes - 60

      modify_and_ship(enc, builder, secondary_code[ref.code], charge_units(mins))
    end

    if ref.scoring_minutes.to_i > 15
      modify_and_ship(enc, builder, '96136', '1')

      if ref.scoring_minutes.to_i > 45
        modify_and_ship(enc, builder, '96137', charge_units(ref.scoring_minutes - 30, 30, 16))
      end
    end

    if ref.tech_scoring_minutes.to_i > 15
      modify_and_ship(enc, builder, '96138', '1')

      if ref.tech_scoring_minutes.to_i > 45
        modify_and_ship(enc, builder, '96139', charge_units(ref.tech_scoring_minutes - 30, 30, 16))
      end
    end

    if ref.computer_test_count.to_i > 0
      modify_and_ship(enc, builder, '96146', ref.computer_test_count.to_s)
    end

    enc.shipped_hp_billing = hp_data
    enc.save
  end

  private

  def secondary_code
    @__secondary_code__ ||= {
      96116 => '96121',
      96130 => '96131',
      96132 => '96133'
    }
  end

  def charge_units(mins, base=60, leftover=31)
    units, mod = mins.divmod(base)
    units += 1 if mod >= leftover
    units = 1 if units.zero?
    units.to_s
  end

  def modify_and_ship(enc, builder, cpt, units)
    builder.xml.doc.at('cpt_code').content = cpt
    builder.xml.doc.at('charge_units').content = units
    ship_note(enc, builder, true)
  end
end
