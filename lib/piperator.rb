require 'piperator/version'
require 'piperator/pipeline'
require 'piperator/io'
require 'piperator/builder'

# Top-level shortcuts
module Piperator
  # Build a new pipeline using DSL. This enables easy control of the pipeline
  # stucture.
  #
  #   Piperator.build do
  #     wrap [1, 2, 3]
  #     pipe(-> (enumerable) { enumerable.map { |i| i + 1 } })
  #   end
  #   # => Pipeline that returns [2, 3, 4] called
  #
  #   # Alternatively, the Builder is also given as argument to the block
  #   Piperator.build do |p|
  #     p.wrap [1, 2, 3]
  #     p.pipe(-> (enumerable) { enumerable.map { |i| i + 1 } })
  #   end
  #   # This is similar, but allows access to instance variables.
  #
  # @return [Pipeline] Pipeline containing defined steps
  def self.build(&block)
    return Pipeline.new unless block_given?

    Builder.new(block&.binding).tap do |builder|
      if block.arity.positive?
        yield builder
      else
        builder.instance_eval(&block)
      end
    end.to_pipeline
  end

  # Build a new pipeline from a callable or an enumerable object
  #
  # @see Piperator::Pipeline.pipe
  # @param enumerable An object responding to call(enumerable)
  # @return [Pipeline] A pipeline containing only the callable
  def self.pipe(enumerable)
    Pipeline.pipe(enumerable)
  end

  # Build a new pipeline from a from a non-callable, i.e. string, array, etc.
  #
  # @see Piperator::Pipeline.wrap
  # @param value A raw value which will be passed through the pipeline
  # @return [Pipeline] A pipeline containing only the callable
  def self.wrap(value)
    Pipeline.wrap(value)
  end
end
