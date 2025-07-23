class Hash
  def recursively_delete_keys! *keys_to_delete
    keys_to_delete.each { |k| delete k }
    values.each { |v| v.recursively_delete_keys!(*keys_to_delete) if v.is_a?(Hash) || v.is_a?(Array) }
    self
  end

  def recursively_replace_keys! &block
    keys.each do |k|
      v = self[k]
      mk = yield k
      if k != mk
        self[mk] = delete k
      end
      v.recursively_replace_keys!(&block) if v.is_a?(Hash) || v.is_a?(Array)
    end
    self
  end

  def recursively_stringify_keys!
    recursively_replace_keys! { |k| k.to_s }
  end

  def recursively_remove_by_value! &block
    self.delete_if { |k, v|
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

  def recursively_replace_values &block
    each_with_object({ }) { |(k, v), result|
      result[k] = (v.is_a?(Hash) || v.is_a?(Array)) ? v.recursively_replace_values(&block) : yield(k, v)
    }
  end
end
