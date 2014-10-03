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

  private

  def initialize custom_processors = {}, &block
    @default_proc = block
    processors.merge! custom_processors
  end

  def processors
    @processors ||= build_processors_hash
  end

  def build_processors_hash
    hash = { Object => default_proc }
    hash.default_proc = method(:match_ancestry)
    hash
  end

  def match_ancestry hash, target
    target.class.ancestors.each do |ancestor|
      return processors[ancestor] if processors.has_key?(ancestor)
    end
  end

  def default_proc
    @default_proc ||= lambda{|t| t }
  end
end
