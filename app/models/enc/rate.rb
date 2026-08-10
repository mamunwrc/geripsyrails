module Enc
  class Rate
    class <<self
      def rate(*ids, &blk)
        ids.each do |id|
          rates[id] = new(id, &blk)
        end
      end

      def rates
        @__rates__ ||= {}
      end
    end

    PROVIDERS = [:multi, :medicaid, :medicare, :medicare_hmo]

    def initialize(id, &blk)
      @id = id
      PROVIDERS.each {|e| instance_variable_set "@#{e}", 0}
      instance_eval(&blk)
    end

    def run(providers)
      case providers.size
      when 0
        0
      when 1
        send providers.first
      else
        if 'medicare'.in?(providers)
          multi
        elsif 'medicare_hmo'.in?(providers)
          medicare_hmo
        elsif 'medicaid'.in?(providers)
          medicaid
        else
          0
        end
      end
    end

    PROVIDERS.each do |provider|
      class_eval <<-EOM
        def #{provider}(val=nil)
          return @#{provider} unless val
          @#{provider} = val
        end
      EOM
    end

    def other
      medicaid
    end

    rate '90791', '90839' do
      medicare 115_19
      medicaid 59_78
      medicare_hmo 135_88
      multi 146_92
    end

    rate '90832' do
      medicare 55_44
      medicaid 25_00
      medicare_hmo 68_70
      multi 70_71
    end

    rate '90834' do
      medicare 73_78
      medicaid 37_42
      medicare_hmo 92_00
      multi 94_11
    end

    rate '90837' do
      medicare 109_85
      medicare_hmo 137_00
      multi 140_12
    end

    rate '90846' do
      medicare 88_96
      medicare_hmo 111_20
      multi 113_47
    end

    rate '90847' do
      medicare 91_90
      medicare_hmo 114_87
      multi 117_22
    end

    rate '90853' do
      medicare 25_00
      medicare_hmo 25_00
      multi 25_00
    end
  end
end

