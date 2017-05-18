require 'spec_helper'

RSpec.describe Piperator::Pipeline do
  let(:add1) { ->(input) { input.lazy.map { |i| i + 1 } } }
  let(:square) { ->(input) { input.lazy.map { |i| i * i } } }

  describe 'calling' do
    it 'calls through all chain pipes in order' do
      chain = Piperator::Pipeline.new([add1, square])
      expect(chain.call([1, 2, 3]).to_a).to eq([4, 9, 16])
    end

    it 'returns original enumerable when chain is empty' do
      input = [1, 2, 3]
      chain = Piperator::Pipeline.new([])
      expect(chain.call(input).to_a).to be(input)
    end
  end

  describe 'composition' do
    it 'runs runs through all input pipes' do
      first = Piperator::Pipeline.new([square])
      second = Piperator::Pipeline.new([add1])
      expect((first + second).call([1, 2, 3]).to_a).to eq([2, 5, 10])
    end

    it 'can compose callables' do
      pipeline = Piperator::Pipeline.new
      expect((pipeline + add1 + square).call([1, 2, 3]).to_a).to eq([4, 9, 16])
    end

    it 'aliases + to pipe' do
      pipeline = Piperator::Pipeline.new
      expect((pipeline.pipe(add1)).call([1]).to_a).to eq([2])
    end
  end
end
