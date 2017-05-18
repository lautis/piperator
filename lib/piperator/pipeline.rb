module Piperator
  class Pipeline
    def self.pipe(callable)
      Pipeline.new([callable])
    end

    def self.call(enumerable)
      enumerable
    end

    def initialize(chains = [])
      @chains = chains
    end

    def call(enumerable)
      @chains.reduce(enumerable) { |chain, memo| memo.call(chain) }
    end

    def +(other)
      Pipeline.new(@chains + [other])
    end

    alias pipe +
  end
end
