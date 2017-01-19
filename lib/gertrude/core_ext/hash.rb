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

  def deep_stringify_keys!
    deep_transform_keys!(&:to_s)
  end

  def deep_transform_keys!(&block)
    _deep_transform_keys_in_object!(self, &block)
  end

  private
  def _deep_transform_keys_in_object!(object, &block)
    case object
      when Hash
        object.keys.each do |key|
          value = object.delete(key)
          object[yield(key)] = _deep_transform_keys_in_object!(value, &block)
        end
        object
      when Array
        object.map! {|e| _deep_transform_keys_in_object!(e, &block)}
      else
        object
    end
  end
end