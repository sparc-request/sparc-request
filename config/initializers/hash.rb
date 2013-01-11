class Hash
  def reverse_hash_to_symbols
    new_hash = {}
    self.each do |k,v|
      new_hash[v.to_sym] = k.to_s
    end

    new_hash
  end

  def reverse_hash_to_strings
    new_hash = {}
    self..each do |k,v|
      new_hash[v.to_s] = k.to_s
    end

    new_hash
  end
end
