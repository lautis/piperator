require 'spec_helper'
require 'piperator/io'

RSpec.describe Piperator::IO do
  KILOBYTE = 1024

  describe '#read' do
    subject { Piperator::IO.new(["foo", "bar"].each) }

    it 'reads specific number of bytes' do
      expect(subject.read(4)).to eq('foob')
    end

    it 'buffers rest and returns on next read' do
      expect(subject.read(2)).to eq('fo')
      expect(subject.read(2)).to eq('ob')
      expect(subject.read(2)).to eq('ar')
    end

    it 'returns nil when at end of enumerable' do
      expect(subject.read(6)).to eq('foobar')
      expect(subject.read).to be_nil
    end

    it 'defaults to returning items one by one' do
      expect(subject.read).to eq('foo')
    end
  end

  describe '#pos' do
    subject { Piperator::IO.new(%w[123 456].each, flush_threshold: 4) }

    it 'is correctly set when using the default #read' do
      expect { subject.read }.to change(subject, :pos).to(3)
    end

    it 'is correctly set when performing a partial #read' do
      expect { subject.read(4) }.to change(subject, :pos).to(4)
    end

    it 'is aliased as #tell' do
      expect { subject.read }.to change(subject, :tell).to(3)
    end
  end

  describe '#gets' do
    subject { Piperator::IO.new(["foo\n", "bar\n"].each) }

    it 'returns characters until the separator' do
      expect(subject.gets).to eq("foo\n")
    end

    it 'handles split UTF-8 characters' do
      broken = 'ä'.force_encoding(Encoding::ASCII_8BIT)
      subject = Piperator::IO.new(
        [
          'foo',
          "\nb".force_encoding(Encoding::ASCII_8BIT) + broken[0],
          broken[1] + "r\n"
        ].each
      )
      expect(subject.gets).to eql("foo\n")
      expect(subject.gets).to eql("bär\n")
    end

    it 'returns the last incomplete line when stream closes' do
      subject = Piperator::IO.new(["foo\n", "bar"].each)
      subject.read
      expect(subject.gets).to eq('bar')
    end

    it 'responds to gets with nil when enumerable is exhausted' do
      2.times { subject.gets }
      expect(subject.gets).to be_nil
    end

    it 'uses bytes for indices' do
      subject = Piperator::IO.new(["foo®\nbar\n"].each)
      expect(subject.gets.force_encoding('UTF-8')).to eq("foo®\n")
      expect(subject.gets).to eq("bar\n")
    end
  end

  describe '#flush' do
    subject { Piperator::IO.new(['a' * 16 * KILOBYTE].each) }
    let(:flush_threshold) { Piperator::IO::FLUSH_THRESHOLD }

    it 'flushes read data' do
      subject.read(1 * KILOBYTE)
      expect { subject.flush }
        .to change(subject, :used).by(-1 * KILOBYTE)
    end

    it 'does not flush on small reads' do
      subject.read(1 * KILOBYTE)
      expect { subject.read(1 * KILOBYTE) }
        .not_to change(subject, :used)
    end

    it 'flushes automatically when the whole buffer is read' do
      subject.read(1 * KILOBYTE)
      expect { subject.read(15 * KILOBYTE) }
        .to change(subject, :used).to(0)
    end

    it 'flushes automatically when more than flush threshold is flushable' do
      subject = Piperator::IO.new(['a' * (flush_threshold + 1)].each)
      expect { subject.read(flush_threshold) }
        .to change(subject, :used).to(1)
    end
  end

  describe '#peek' do
    subject { Piperator::IO.new(%w[foo bar].each) }

    it 'reads specific number of bytes' do
      expect(subject.peek(4)).to eq('foob')
    end

    it 'does not change pointer for read' do
      subject.peek(2)
      expect(subject.read(4)).to eq('foob')
    end

    it 'peeking to EOF works' do
      expect(subject.peek(20)).to eq('foobar')
    end

    it 'peeking to EOF does not change pointer for read' do
      subject.peek(10)
      expect(subject.read(4)).to eq('foob')
    end
  end

  describe 'eof?' do
    subject { Piperator::IO.new(%w[foo bar].each) }

    it 'is not at eof when starting' do
      expect(subject).not_to be_eof
    end

    it 'is eof when at end' do
      subject.read(10)
      expect(subject).to be_eof
    end
  end
end
