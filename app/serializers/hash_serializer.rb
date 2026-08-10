class HashSerializer < Hashie::Mash
  def self.dump(obj)
    obj
  end

  def self.load(hash)
    new(hash || {})
  end
end
