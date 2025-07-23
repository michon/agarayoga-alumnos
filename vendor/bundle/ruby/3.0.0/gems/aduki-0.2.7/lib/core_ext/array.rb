class Array
  def recursively_delete_keys! *keys
    self.each { |v| v.recursively_delete_keys!(*keys) if v.is_a?(Hash) || v.is_a?(Array) } ; self
  end

  def recursively_replace_keys! &block
    self.each { |v| v.recursively_replace_keys!(&block) if v.is_a?(Hash) || v.is_a?(Array) } ; self
  end

  def recursively_replace_values &block
    result = []
    each_with_index { |v, i|
      result << ((v.is_a?(Hash) || v.is_a?(Array)) ? v.recursively_replace_values(&block) : yield(i, v))
    }
    result
  end

  def recursively_remove_by_value! &block
    self.delete_if { |v|
      if v.is_a? Hash
        v.recursively_remove_by_value! &block
        v.empty?
      elsif v.is_a? Array
        v.recursively_remove_by_value! &block
        v.empty?
      else
        yield v
      end
    }
  end

end
