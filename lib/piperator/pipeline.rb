module Piperator
  # Pipeline is responsible of composition of a lazy enumerable from callables.
  # It contains a collection of pipes that respond to #call and return a
  # enumerable.
  #
  # For streaming purposes, it usually is desirable to have pipes that takes
  # a lazy Enumerator as an argument a return a (modified) lazy Enumerator.
  class Pipeline
    # Build a new pipeline from a callable or an enumerable object
    #
    # @param callable An object responding to call(enumerable) and returns Enumerable
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

    def initialize(pipes = [])
      @pipes = pipes
    end

    # Compute the pipeline and return a lazy enumerable with all the pipes.
    #
    # @param enumerable Argument passed to the first pipe in the pipeline.
    # @return [Enumerable] A lazy enumerable containing all the pipes
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
    # @param other A pipe to append in pipeline. Responds to #call.
    # @return [Pipeline] A new pipeline instance
    def pipe(other)
      Pipeline.new(@pipes + [other])
    end
  end
end
