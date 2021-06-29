require 'spec_helper'



RSpec.describe "Piperator.infinite_io" do
  repeated_string = "foobar\n"
  infinite_foobar = Enumerator.new { |y| loop { y << repeated_string } }

  describe '#read' do
    subject { proc { |&b| Piperator.infinite_io(infinite_foobar) { |x| b.(x) } } }

    it 'reads specific number of bytes' do
      subject.call do |io|
        expect(io.read(4)).to eq('foob')
      end
    end

    it 'buffers rest and returns on next read' do
      subject.call do |io|
        expect(io.read(2)).to eq('fo')
        expect(io.read(2)).to eq('ob')
        expect(io.read(2)).to eq('ar')
      end
    end

    it 'does not try to reach the end before working' do
      n = 100000
      subject.call do |io|
        expect(io.read(n * repeated_string.length)).to eq(repeated_string * n)
      end
    end
  end

  describe '#gets' do
    it 'returns characters until the separator' do
      Piperator.infinite_io(infinite_foobar) do |io|
        expect(io.gets).to eq(repeated_string)
      end
    end

    it 'responds to gets with nil when enumerable is exhausted' do
      n = 2
      Piperator.infinite_io(([repeated_string] * n).each) do |io|
        n.times { expect(io.gets).to eq(repeated_string) }
        expect(io.gets).to be_nil
      end
    end
  end

  describe '#eof?' do
    it 'returns eof when enumerable is exhausted' do
      n = 2
      Piperator.infinite_io(([repeated_string] * n).each) do |io|
        expect(io.eof?).to be_falsey
        n.times { expect(io.gets).to eq(repeated_string) }
        expect(io.eof?).to be_truthy
      end
    end
  end

  describe "#each_line" do
    it 'reevaluates line breaks' do
      Piperator.infinite_io(["foo\n", "bar\n", "baz\nbmp"].lazy.each) do |io|
        expect(io.each_line.map(&:strip)).to eq(["foo", "bar", "baz", "bmp"])
      end
    end
  end

end
