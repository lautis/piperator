module Piperator
  class Pipeline
    def initialize(chains = [])
      @chains = chains
    end

    def call(enumerable)
      @chains.reduce(enumerable) { |chain, memo| memo.call(chain) }
    end

    def +(other)
      Pipeline.new(@chains + [other])
    end
  end
end
