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
    hash.default_proc = lambda{|hash,target| match_eql(hash, target) || match_ancestry(hash, target) }
    hash
  end

  def match_ancestry hash, target
    target.class.ancestors.each do |ancestor|
      return processors[ancestor] if processors.has_key?(ancestor)
    end
  end

  def match_eql hash, target
    key, processor = processors.detect{|key, processor| key == target }
    processor
  end

  def default_proc
    @default_proc ||= lambda{|t| t }
  end
end
