require 'aduki'

class Aduki::RecursiveHash < Hash
  def []= key, value
    return super(key, value) unless key.is_a? String

    k0, k1 = key.split(/\./, 2)

    if k0.match(/\[\d+\]$/)
      getter = k0.gsub(/\[\d+\]$/, '')
      index  = k0.gsub(/.*\[(\d+)\]$/, '\1').to_i
      subarray = self[getter] || []
      if k1
        subarray[index] ||= Aduki::RecursiveHash.new
        subarray[index][k1] = value
      else
        subarray[index] = value
      end
      super getter, subarray
    else
      return super(key, value) if k1.nil?
      existing = self[k0]
      subhash = (existing.is_a? Hash) ? existing : Aduki::RecursiveHash.new
      subhash[k1] = value
      super k0, subhash
    end
  end

  def copy other
    other.each { |k, v| self[k]= v }
    self
  end
end
