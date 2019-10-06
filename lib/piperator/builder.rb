module Piperator
  class Builder
    def initialize(pipeline = Pipeline.new)
      @pipeline = pipeline
    end

    def to_pipeline
      @pipeline
    end

    %i[pipe wrap].each do |method|
      define_method method do |value|
        @pipeline = @pipeline.send(method, value)
      end
    end
  end
end
