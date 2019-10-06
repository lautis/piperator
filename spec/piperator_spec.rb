require 'spec_helper'

RSpec.describe Piperator do
  it 'has a version number' do
    expect(Piperator::VERSION).not_to be nil
  end

  it 'can start piping from Piperator' do
    expect(Piperator.pipe(->(i) { i }).call([1, 2, 3]).to_a).to eq([1, 2, 3])
  end

  it 'can start wrap directly from Piperator' do
    expect(Piperator.wrap([1]).call.to_a).to eq([1])
  end

  it 'can build a pipeline with block' do
    pipeline = Piperator.pipeline do
      wrap [4, 5]
      pipe(->(input) { input.lazy.map { |i| i + 1 } })
      pipe(->(input) { input.lazy.map { |i| i * 2 } })
    end
    expect(pipeline.call.to_a).to eq([10, 12])
  end

  it 'can build a pipeline with block referencing methods/variables outside of the block scope' do
    def should_do_step?
      true
    end
    pipeline = Piperator.pipeline do
      wrap [4, 5]
      pipe(->(input) { input.lazy.map { |i| i + 1 } }) if should_do_step?
      pipe(->(input) { input.lazy.map { |i| i * 2 } })
    end
    expect(pipeline.call.to_a).to eq([10, 12])
  end
end
