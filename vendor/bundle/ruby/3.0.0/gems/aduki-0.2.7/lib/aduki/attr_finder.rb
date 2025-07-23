class Aduki::AttrFinder
  if defined? ActiveSupport
    def self.camelize    str ; str.to_s.camelize    ; end
    def self.singularize str ; str.to_s.singularize ; end
    def self.pluralize   str ; str.to_s.pluralize   ; end
  else
    def self.camelize str
      str.split(/\//).map { |s| s.gsub(/(^|_)([a-z])/) { |m| $2.upcase } }.join("::")
    end
    def self.singularize str
      str.to_s.gsub(/ies$/, "y").gsub(/s$/, '')
    end
    def self.pluralize str
      str.to_s.gsub(/y$/, "ies").gsub(/([^s])$/, '\1s')
    end
  end

  def self.hashify_args a
    return a.first if a.first.is_a? Hash
    a.inject({ }) { |hash, arg|
      if arg.is_a?(Hash)
        hash.merge arg
      else
        hash[arg] = camelize arg.to_s
        hash
      end
    }
  end

  def self.attr_finders_text finder, id, *args
    hashify_args(args).map { |name, klass|
      attr_finder_text finder, id, name, klass
    }.join("\n")
  end

  def self.attr_finder_text finder, id, name, klass
    id_method = "#{name}_#{id}"
    <<EVAL
remove_method :#{id_method}  if method_defined?(:#{id_method})
remove_method :#{id_method}= if method_defined?(:#{id_method}=)
remove_method :#{name}       if method_defined?(:#{name})
remove_method :#{name}=      if method_defined?(:#{name}=)

attr_reader :#{id_method}

def #{id_method}= x
  @#{id_method}= x
  @#{name} = nil
end

def #{name}
  @#{name} ||= #{klass}.#{finder}(@#{id_method}) unless @#{id_method}.nil? || @#{id_method} == ''
  @#{name}
end

def #{name}= x
  @#{name} = x
  @#{id_method} = x ? x.#{id} : nil
end
EVAL
  end

  def self.one2many_attr_finder_text finder, id, name, options={ }
    singular = singularize name.to_s
    klass    = options[:class_name] || camelize(singular)
    id_method = "#{singular}_#{pluralize id}"
    <<EVAL
remove_method :#{id_method}  if method_defined?(:#{id_method})
remove_method :#{id_method}= if method_defined?(:#{id_method}=)
remove_method :#{name}       if method_defined?(:#{name})
remove_method :#{name}=      if method_defined?(:#{name}=)

attr_reader :#{id_method}

def #{id_method}= x
  @#{id_method} = x
  @#{name}      = nil
end

def #{name}
  @#{name} ||= #{klass}.#{finder} @#{id_method} unless @#{id_method}.nil?
  @#{name}
end

def #{name}= x
  @#{id_method} = x ? x.map(&:#{id}) : nil
  @#{name}      = x
end
EVAL
  end

end
