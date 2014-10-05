require 'double_dispatcher'

class DoubleDispatcher
  class Deep < DoubleDispatcher
    private

    def specific_initial_processors
      {
        Hash => method(:dispatch_hash),
        Enumerable => method(:dispatch_array),
      }
    end

    def dispatch_array object
      object.inject([]) do |array, value|
        array << dispatch(value)
      end
    end

    def dispatch_hash object
      object.inject({}) do |hash, key_value|
        key, value = key_value
        hash[key] = dispatch(value)
        hash
      end
    end
  end
end

