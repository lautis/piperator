module Piperator
  class Builder
    def initialize(saved_binding, pipeline = Pipeline.new)
      @pipeline = pipeline
      @saved_binding = saved_binding
    end

    def to_pipeline
      @pipeline
    end

    def method_missing(method_name, *arguments, &block)
      if @saved_binding.receiver.respond_to?(method_name, true)
        @saved_binding.receiver.send(method_name, *arguments, &block)
      else
        super
      end
    end

    def respond_to_missing?(meth, include_private = false)
      @saved_binding.receiver.respond_to?(method_name, include_private) || super
    end

    %i[pipe wrap].each do |method|
      define_method method do |value|
        @pipeline = @pipeline.send(method, value)
      end
    end
  end
end
