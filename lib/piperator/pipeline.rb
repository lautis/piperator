module Piperator
  # Pipeline is responsible of composition of a lazy enumerable from callables.
  # It contains a collection of parts that respond to #call(enumerable) and
  # return a enumerable.
  class Pipeline
    # Build a new pipeline from a callable or an enumerable object
    #
    # @param callable An object responding to call(enumerable) and returns Enumerable or an Enumerable
    # @return [Pipeline] A pipeline containing only the callable
    def self.pipe(callable)
      if callable.respond_to?(:call)
        Pipeline.new([callable])
      else
        Pipeline.new([->(_) { callable }])
      end
    end

    # Returns enumerable given as an argument without modifications. Usable when
    # Pipeline is used as an identity transformation.
    #
    # @param enumerable [Enumerable]
    # @return [Enumerable]
    def self.call(enumerable = [])
      enumerable
    end

    def initialize(chains = [])
      @chains = chains
    end

    # Compute the pipeline and return a lazy enumerable with all the parts.
    #
    # @param enumerable Argument given to the first part in the pipeline
    # @return [Enumerable] A lazy enumerable containing all the parts
    def call(enumerable = [])
      @pipes.reduce(enumerable) { |pipe, memo| memo.call(pipe) }
    end

    # Compute the pipeline and strictly evaluate the result
    #
    # @return [Array]
    def to_a(enumerable = [])
      call(enumerable).to_a
    end

    # Add a new part to the pipeline
    #
    # @param other A part to append in pipeline. Responds to #call.
    # @return [Pipeline] A new pipeline instance
    def pipe(other)
      Pipeline.new(@chains + [other])
    end
  end
end
