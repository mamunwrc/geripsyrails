class Enc::DataValidator < ActiveModel::Validator
  UnknownFormError = Class.new(StandardError)

  attr_reader :enc

  def validate(enc)
    @enc = enc

    case enc.cpt_encounter_code
    when "90839"
      validate_90839
    when "90853"
      validate_90853
    when %r(^907)
      validate_907xx
    when %r(^908)
      validate_908xx
    when %r(^9896)
      validate_9896x
    when %r(^961)
      validate_9611x
    when 'TP', 'GBH1'
      validate_tp
    else
      raise UnknownFormError
    end
  end

  def validate_none
    #noop
  end

  def self.validate_all(enc)
    Enc::Encounter::DATA_VALIDTORS.each{|v| v.new.validate enc }
  end

protected

  def base_field
    self.class::BASE_FIELD
  end

  def enc_data(field = nil)
    if field
      parts = field.to_s.split(".")
      if parts.size == 1
        enc_data[field]
      else
        parts[1..-1].inject(enc_data[parts[0]]){|m,k| m[k] }
      end
    else
      enc[base_field]
    end
  end

  def enc_error(field, msg)
    enc.errors.add(base_field, "'#{field}' #{msg}")
    false
  end

  def ref_lookups(prefix)
    case prefix
    when :BOOLEAN
      Hash[[ %w(Y Yes), %w(N No) ]]
    when :ICDREFS
      lambda {
        Hash[
          Ref::Icd.pluck(:icd, :description).
            map{|key, val| [key, [key, val].join(' - ')] }
        ]
      }
    else
      lambda do
        Hash[Ref::Lookup.where(keyprefix: prefix).pluck(:keyname, :keyvalue)]
      end
    end
  end

  def assert_hash_like(field)
    case val = enc_data(field)
    when Hash
      return true
    else
      enc_error(field, val.blank? ? "can't be blank" : "is invalid")
    end
  end

  def assert_time(field, **opts)
    return unless assert_present field, opts

    begin
      !!Time.parse("2017-01-01 %s:01 UTC" % enc_data(field))
    rescue
      enc_error(field, "is not a valid time")
    end
  end

  def assert_date(field, **opts)
    return unless assert_present field, opts

    begin
      !!Date.parse(enc_data(field))
    rescue
      enc_error(field, "is not a valid date")
    end
  end

  def assert_relation(field, related, **opts)
    return unless assert_present(field, opts)

    unless related[enc_data(field)]
      enc_error(field, "is invalid")
      return false
    end

    true
  end

  def assert_number(field, **opts)
    return unless assert_present(field, opts)

    unless Integer === enc_data(field)
      enc_error(field, 'must be a number')
      return false
    end

    true
  end

  def assert_present(field, **opts)
    if enc_data(field).blank?
      enc_error(field, "can't be blank") unless opts[:optional]
      return false
    end

    true
  end

  def assert_picked_one(field, choices, **opts)
    unless opts[:presence_checked]
      return unless assert_present field, opts
    end

    return unless picked = opts[:picked] || enc_data(field)

    valid =
      if opts[:freetext] and picked.name == 'FREETEXT'
        picked.freetext.present?
      elsif picked.name.present?
        choices2 = Symbol === choices ? ref_lookups(choices) : choices
        choices3 = choices2.respond_to?(:call) ? choices2.call : choices2
        choices3.any? do |k,v|
          "#{picked.name}" == "#{k}" #and "#{picked.val}" == "#{v}"
        end
      end

    valid.tap do
      if !valid and !opts[:dont_insert_error]
        enc_error(field, "is not a valid option")
      end

      yield(valid) if block_given?
    end
  end

  def assert_picked_many(field, choices, **opts)
    return unless assert_present field, opts

    results = []

    (enc_data(field) || []).each do |picked|
      assert_picked_one field, choices, opts.merge({
        picked: picked,
        dont_insert_error: true,
        presence_checked: true,
      }) do |valid|
        results.push(valid)
      end

      unless results.all?
        enc_error(field, "has invalid option")
        break
      end
    end

    results.all?
  end

end
