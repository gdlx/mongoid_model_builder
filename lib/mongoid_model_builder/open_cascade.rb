class OpenCascade < OpenHash
  
  def method_missing(sym, *args, &blk)
    type = sym.to_s[-1,1]
    name = sym.to_s.gsub(/[=!?]$/, '')
    name = name[1..-1] if name[0] == '_' && !key?(name) 
    name = name.to_sym
    
    case type
    when '='
      self[name] = args.first
    when '!'
      #@hash.__send__(name, *args, &blk)
      __send__(name, *args, &blk)
    when '?'
      self[name]
    else
      if key?(name)
        self[name] = transform_entry(self[name])
      else
        self[name] = OpenCascade.new #self.class.new
      end
    end
  end
  
  def each
    super do |name, entry|
      yield([name, transform_entry(entry)])
    end
  end
end