class Enc::ServiceDateDupCheck
  class <<self
    def run(patient_id, cpt, date, enc_id=nil)
      @checker = new(patient_id, date, enc_id)
      if rules = rules_store[cpt]
        @checker.instance_eval(&rules)
      end

      @checker.tap(&:run!)
    end

    def rules(*codes, &rules_block)
      codes.each do |code|
        rules_store[code] = rules_block
      end
    end

    private

    def rules_store
      @__rules_store__ ||= Hashie::Mash.new
    end
  end

  BLOCKERS_9083x = %w(1 2 3 4 5 6 7)
  BLOCKERS_9084x = %w(8 9)

  # CPT can be actual code or val from therapeutic_communication.service_conducted
  rules *(BLOCKERS_9083x + %w(90832 90834 90837)) do
    query_with &fu_query
    blockers BLOCKERS_9083x
  end

  rules *(BLOCKERS_9084x + %w(90846 90847)) do
    query_with &fu_query
    blockers BLOCKERS_9084x
  end

  rules '90853' do
    query_with { where.not(cpt_encounter_code: '90832') }
  end

  def initialize(patient_id, date, enc_id=nil)
    @patient = Pat::Patient.find patient_id
    @date = date
    @id = enc_id
  end

  attr_reader :result

  def ok?
    @result.blank?
  end

  def dup?
    !ok?
  end

  def run!
    @result = q.non_dupable.
      where.not(id: @id).
      service_date_between(@date, @date.tomorrow)
  end

  def base_query
    @base_query ||= @patient.encounters.signed
  end

  def q
    @query_extras ? base_query.instance_exec(blockers, &@query_extras) : base_query
  end

  private

  def query_with(&query)
    @query_extras = query
  end

  def blockers(blocking_fu_ids=nil)
    return @__blockers__ unless blocking_fu_ids
    @__blockers__ = blocking_fu_ids
  end

  def fu_query
    # Check if existing 90832 with existing blocking CPT
    # OR any blocking non 90853/follow ups
    proc {|blockers|
      where(cpt_encounter_code: '90832').
      where("therapeutic_communication -> 'service_conducted' ->> 'name' IN (?)", blockers).
      or(where.not(cpt_encounter_code: ['90853', '90832']))
    }
  end
end
