require 'piperator/version'
require 'piperator/pipeline'

module Piperator
  # Build a new pipeline from a callable or an enumerable object
  #
  # @see Piperator::Pipeline.pipe
  # @param callable An object responding to call(enumerable) and returns Enumerable or an Enumerable
  # @return [Pipeline] A pipeline containing only the callable
  def self.pipe(enumerable)
    Pipeline.pipe(enumerable)
  end
end
