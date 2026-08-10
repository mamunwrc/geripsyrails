module HealthpacCode
  extend ActiveSupport::Concern

  def hp_code(override=nil)
    _id =
      if override
        override
      else
        hp_code_key ? send(hp_code_key) : id
      end
    hp_code_base + _id.to_s.rjust(3, "0")
  end

  def hp_code_base
    self.class.hp_code_base.dup
  end

  def hp_code_key
    self.class.hp_code_key
  end

  module ClassMethods
    def hp_code_base(base=nil)
      return @__hp_code_base__ unless base
      @__hp_code_base__ = base
    end

    def hp_code_key(key=nil)
      return @__hp_code_key__ unless key
      @__hp_code_key__ = key
    end
  end
end
