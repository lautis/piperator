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
end
