require 'spec_helper'

# rubocop:disable Metrics/BlockLength
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

  describe '.build' do
    it 'returns a new Pipeline' do
      expect(Piperator.build).to be_a(Piperator::Pipeline)
    end

    it 'can build a pipeline with block' do
      counter = 0
      def ok?
        true
      end
      pipeline = Piperator.build do
        wrap [4, 5] if ok?
        pipe(->(input) { input.lazy.map { |i| i + 1 } })
        lazy do
          counter += 1
          ->(input) { input.lazy }
        end
        pipe(->(input) { input.lazy.map { |i| i * 2 } })
      end
      expect(pipeline.call.to_a).to eq([10, 12])
      expect(counter).to eq(1)
    end

    it 'can call private methods' do
      klass = Class.new do
        def pipeline
          Piperator.build do
            wrap [4, 5]
            pipe plus1
          end
        end

        private

        def plus1
          ->(input) { input.lazy.map { |i| i + 1 } }
        end
      end

      expect(klass.new.pipeline.to_a).to eq([5, 6])
    end

    it 'gives builder as argument' do
      @ok = -> { true }

      expect(Piperator.build do |pipeline|
        pipeline.wrap [4, 5] if @ok
        pipeline.pipe(->(input) { input.lazy.map { |i| i + 1 } })
      end.to_a).to eq([5, 6])
    end
  end
end
