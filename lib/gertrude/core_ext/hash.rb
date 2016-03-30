class Hash
  def has_deep_key?(key)
    self.has_key?(key) || any? { |k, v| v.has_deep_key?(key) if v.is_a? Hash }
  end

  def has_deep_value?(value)
    self.has_value?(value) || any? { |k, v| v.has_deep_value?(value) if v.is_a? Hash }
  end

  def deep_find(key, hash = self)
    return hash[key] if hash.respond_to?(:key?) && hash.key?(key)
    return unless hash.is_a?(Enumerable)
    found = nil
    hash.find { |*x| found = deep_find(key, x.last) }
    found
  end
end