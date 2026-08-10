unless Usr::User.find_by email: "admin@geripsy.com"
  admin = Usr::User.new
  admin.email = "admin@geripsy.com"
  admin.password = "password123"
  admin.first_name = "Super"
  admin.last_name = "Admin"

  admin.save
  admin.add_role :super_admin
end

Ref::Lookup.delete_all

encounter_lookups = File.read File.expand_path('../lookups/encounter_lookups.json', __FILE__)
generic_lookups   = File.read File.expand_path('../lookups/ref_lookups.json', __FILE__)
[[encounter_lookups, 'encounters'], [generic_lookups, 'main']].each do |lookup_json, group|
  JSON.parse(lookup_json).each do |prefix, opts|
    opts.each do |opt|
      create_data = {keyvalue: opt['value']}
      create_data[:description] = opt['description'] if opt['description']
      Ref::Lookup.create_with(create_data).find_or_create_by({
        group: group,
        keyprefix: prefix,
        keyname: opt['key']
      })
    end
  end
end

Dir.glob(Rails.root + 'db/lookups/icd10*').each do |f|
  file = File.read(f)
  group = f.split('/').last.split('-').last.split('.').first[-1]
  reseed = ENV['RESEED_ICDS'] == 'yes'

  Ref::Icd::import(group, JSON::parse(file), reseed)
end

freqicds = %w(F43.21 F43.22 F43.23 F43.24 F43.25 F32.0 F32.1 F32.2 F32.3 F32.4 F32.9 F33.0 F33.1 F33.2 F33.3 F33.40 F33.41 F33.9 F34.0 F34.1 F39 F25.9 F41.9 F41.1 F42)
Ref::Icd.where(icd: freqicds).update_all is_common: true

# ensure patients with unmarked status = active
Pat::Patient.where(status: nil).update_all status: 'active'

# Seed the list of insurance providers
JSON.parse(File.read(Rails.root + 'db/insurance_providers.json')).each do |ins|
  Pat::Insurance.find_or_create_by(hp_id_code: ins['id']) {|i| i.name = ins['name']}
end

# Ensure Medicare HMOs marked as such
Pat::Insurance.where(hp_id_code: [4,5,6,7,11,16,22,23]).update_all medicare_hmo: true

# Setup Facilities with alternate HP code to be used
# when an encounter is signed "Non-Part A"
if ENV['SEED_FAC_ALT_POS'] == 'yes'
  [
    [1, 10],
    [2, 11],
    [3, 12],
    [4, 13],
    [5, 14],
    [6, 15],
    [7, 16],
    [8, 17],
    [9, 18]
  ].each do |fid, alt_id|
    begin
      Adm::Facility.find(fid).update!(hp_alt_pos_code: alt_id)
    rescue => e
      puts "Error adding alt pos id: #{[e.class, e.message].join(' => ')}"
    end
  end
end
