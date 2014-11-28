class DoubleDispatcher
  def dispatch target
    processors[target].call target
  end

  def []= key, value
    processors[key]= value
  end

  def for key, &value
    self[key]= value
  end

  def [] key
    processors[key]
  end

  private

  def initialize custom_processors = {}, &block
    @default_proc = block
    processors.merge! custom_processors
  end

  def processors
    @processors ||= build_processors_hash
  end

  def build_processors_hash
    hash = initial_processors
    hash.default_proc = method(:match_ancestry)
    hash
  end

  def initial_processors
    { Object => default_proc }.merge(specific_initial_processors)
  end

  def specific_initial_processors
    {} # template method
  end

  def match_ancestry hash, target
    target.class.ancestors.each do |ancestor|
      return processors[ancestor] if processors.has_key?(ancestor)
    end
  end

  def default_proc
    @default_proc ||= lambda{|t| raise(NotImplementedError.new("Don't know how to process #{t.inspect}")) }
  end
end
