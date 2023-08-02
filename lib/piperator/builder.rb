module Piperator
  # Builder is used to provide DSL-based Pipeline building. Using Builder,
  # Pipelines can be built without pipe chaining, which might be easier if
  # some steps need to be included only on specific conditions.
  #
  # @see Piperator.build
  class Builder
    # Expose a chained method in Pipeline in DSL
    #
    # @param method_name Name of method in Pipeline
    # @see Pipeline
    #
    # @!macro [attach] dsl_method
    #   @method $1
    #   Call Pipeline#$1 given arguments and use the return value as builder state.
    #
    #   @see Pipeline.$1
    def self.dsl_method(method_name)
      define_method(method_name) do |*arguments, &block|
        @pipeline = @pipeline.send(method_name, *arguments, &block)
      end
    end

    dsl_method :lazy
    dsl_method :pipe
    dsl_method :wrap

    def initialize(pipeline = Pipeline.new)
      @pipeline = pipeline
    end

    # Return build pipeline
    #
    # @return [Pipeline]
    def to_pipeline
      @pipeline
    end
  end
end
