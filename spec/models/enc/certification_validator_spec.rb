require 'rails_helper'
require_relative 'data_validator_shared_examples'

RSpec.describe Enc::CertificationValidator, type: :model do
  include_context 'as data validator'
  include_validation_macros :certification

  %w(907xx 908xx 90839 90853).each do |enc_code|
    describe enc_code do
      let(:code) { enc_code }

      has_time_field :start_time
      has_time_field :end_time
    end
  end

end

# vim:ts=2:bs=2:sw=2:et:fdm=marker
