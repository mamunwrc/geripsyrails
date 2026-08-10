class Enc::TpMethodsValidator < Enc::DataValidator

  BASE_FIELD = :tp_methods

protected

  alias_method :validate_908xx, :validate_none
  alias_method :validate_9896x, :validate_908xx
  alias_method :validate_907xx, :validate_none
  alias_method :validate_90839, :validate_none
  alias_method :validate_90853, :validate_none
  alias_method :validate_9611x, :validate_none

  def validate_tp
    return unless assert_picked_many :methods, :TPMETHODS

    check_current_and_target :gai
    check_current_and_target :gaisf
    check_current_and_target :csd
    check_current_and_target :staff
    check_current_and_target :discharge
    check_current_and_target :diffscale
  end

  def check_current_and_target(field)
    meth_names = enc_data['methods'].try(:map, &:name)
    return unless meth_names.include?(field.to_s)
    return unless assert_hash_like field

    %w(current target).each do |f|
      enc_error([field,f]*'.', "can't be blank") if enc_data(field)[f].blank?
    end
  end

end
