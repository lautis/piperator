require 'spec_helper'

RSpec.describe Piperator::Pipeline do
  let(:add1) { ->(input) { input.lazy.map { |i| i + 1 } } }
  let(:square) { ->(input) { input.lazy.map { |i| i * i } } }
  let(:sum) { ->(input) { input.reduce(0, &:+) } }

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

    it 'defaults to empty array when calling' do
      expect(Piperator::Pipeline.new([sum]).call([])).to eq(0)
    end
  end

  describe 'composition' do
    it 'runs runs through all input pipes' do
      first = Piperator::Pipeline.new([square])
      second = Piperator::Pipeline.new([add1])
      expect(first.pipe(second).call([1, 2, 3]).to_a).to eq([2, 5, 10])
    end

    it 'can compose callables' do
      pipeline = Piperator::Pipeline.new
      expect(pipeline.pipe(add1).pipe(square).call([1, 2, 3]).to_a)
        .to eq([4, 9, 16])
    end

    it 'can compose values with using Pipeline#wrap' do
      pipeline = Piperator::Pipeline.wrap([1, 2, 3]).pipe(square)

      expect(pipeline.call.to_a).to eq([1, 4, 9])
    end

    it 'can start composition from empty Pipeline class' do
      expect(Piperator::Pipeline.pipe(add1).call([3]).to_a).to eq([4])
    end

    it 'treats pipeline pipe as an identity transformation' do
      pipeline = Piperator::Pipeline.pipe(add1).pipe(Piperator::Pipeline)
      expect(pipeline.call([1, 2]).to_a).to eq([2, 3])
    end

    it 'can start pipeline from an enumerable' do
      pipeline = Piperator::Pipeline.wrap([1, 2, 3]).pipe(add1)
      expect(pipeline.to_a).to eq([2, 3, 4])
    end

    it 'can do strict evaluation at the end' do
      expect(Piperator::Pipeline.pipe(add1).pipe(sum).call([1, 2, 3])).to eq(9)
    end
  end

  describe '#lazy' do
    it 'gets invoked' do
      counter = 0
      chain = Piperator::Pipeline.pipe(add1).lazy do
        counter += 1
        ->(input) { input.lazy }
      end

      expect(chain.call([1, 2, 3]).to_a).to eq([2, 3, 4])
      expect(counter).to eq(1)
    end

    it 'memoizes its pipe' do
      counter = 0
      chain = Piperator::Pipeline.pipe(add1).lazy do
        counter += 1
        ->(input) { input.lazy }
      end

      expect(chain.call([1, 2, 3]).to_a).to eq([2, 3, 4])
      expect(chain.call([1, 2, 3]).to_a).to eq([2, 3, 4])
      expect(counter).to eq(1)
    end
  end
end
