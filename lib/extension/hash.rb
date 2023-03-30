class Hash
  def deep_merge(other_hash)
    result = self.dup

    other_hash.each do |key, value|
      if value.is_a?(Hash) && self[key].is_a?(Hash)
        result[key] = result[key].deep_merge(value)
      else
        result[key] = value
      end
    end

    result
  end
end