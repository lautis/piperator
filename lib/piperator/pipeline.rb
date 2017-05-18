module Piperator
  # Pipeline is responsible of composition of a lazy enumerable from callables.
  # It contains a collection of parts that respond to #call(enumerable) and
  # return a enumerable.
  class Pipeline
    # Build a new pipeline with callable
    #
    # @param callable An object responding to call(enumerable) and returns Enumerale.
    # @return [Pipeline] A pipeline containing only the callable
    def self.pipe(callable)
      Pipeline.new([callable])
    end

    # Returns enumerable given as an argument without modifications. Usable when
    # Pipeline is used as an identity transformation.
    #
    # @param enumerable [Enumerable]
    # @return [Enumerable]
    def self.call(enumerable)
      enumerable
    end

    def initialize(chains = [])
      @chains = chains
    end

    # Compute the pipeline and return a lazy enumerable with all the parts.
    #
    # @param enumerable Argument given to the first part in the pipeline
    # @return [Enumerable] A lazy enumerable containing all the parts
    def call(enumerable)
      @chains.reduce(enumerable) { |chain, memo| memo.call(chain) }
    end

    # Add a new part to the pipeline
    #
    # @param other A part to append in pipeline. Responds to #call.
    # @return [Pipeline] A new pipeline instance
    def +(other)
      Pipeline.new(@chains + [other])
    end

    alias pipe +
  end
end
