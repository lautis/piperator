require 'English'

module Piperator
  # Pseudo I/O on Enumerators
  class IO
    FLUSH_THRESHOLD = 128 * 1028 # 128KiB

    attr_reader :eof
    attr_reader :pos

    def initialize(enumerator, flush_threshold: FLUSH_THRESHOLD)
      @enumerator = enumerator
      @flush_threshold = flush_threshold
      @buffer = StringIO.new
      @pos = 0
      @buffer_read_pos = 0
      @eof = false
    end

    alias eof? eof
    alias tell pos

    # Return the first bytes of the buffer without marking the buffer as read.
    def peek(bytes)
      while @eof == false && readable_bytes < (bytes || 1)
        @buffer.write(@enumerator.next)
      end
      peek_buffer(bytes)
    rescue StopIteration
      @eof = true
      peek_buffer(bytes)
    end

    # Reads the next "line" from the I/O stream; lines are separated by
    # separator.
    #
    # @param separator [String] separator to split input
    # @param _limit Unused parameter for compatiblity
    # @return [String]
    def gets(separator = $INPUT_RECORD_SEPARATOR, _limit = nil)
      while !@eof && !contains_line?(separator)
        begin
          @buffer.write(@enumerator.next)
        rescue StopIteration
          @eof = true
          nil
        end
      end
      read_with { @buffer.gets(separator) }
    end

    # Flush internal buffer until the last unread byte
    def flush
      if @buffer.pos == @buffer_read_pos
        initialize_buffer
      else
        @buffer.pos = @buffer_read_pos
        initialize_buffer(@buffer.read)
      end
    end

    # Reads length bytes from the I/O stream.
    #
    # @param length [Integer] number of bytes to read
    # @param buffer [String] optional read buffer
    # @return String
    def read(length = nil, buffer = nil)
      return @enumerator.next.tap { |e| @pos += e.bytesize } if length.nil? && readable_bytes.zero?
      @buffer.write(@enumerator.next) while !@eof && readable_bytes < (length || 1)
      read_with { @buffer.read(length, buffer) }
    rescue StopIteration
      @eof = true
      read_with { @buffer.read(length, buffer) } if readable_bytes > 0
    end

    # Current buffer size - including non-freed read content
    #
    # @return [Integer] number of bytes stored in buffer
    def used
      @buffer.size
    end

    private

    def readable_bytes
      @buffer.pos - @buffer_read_pos
    end

    def read_with
      pos = @buffer.pos
      @buffer.pos = @buffer_read_pos

      yield.tap do |data|
        @buffer_read_pos += data.bytesize if data
        @buffer.pos = pos
        flush if flush?
      end
    end

    def peek_buffer(bytes)
      @buffer.string.byteslice(@buffer_read_pos...@buffer_read_pos + bytes)
    end

    def flush?
      @buffer.pos == @buffer_read_pos || @buffer.pos > @flush_threshold
    end

    def initialize_buffer(data = nil)
      @pos += @buffer_read_pos
      @buffer_read_pos = 0
      @buffer = StringIO.new
      @buffer.write(data) if data
    end

    def contains_line?(separator = $INPUT_RECORD_SEPARATOR)
      return true if @eof
      @buffer.string.byteslice(@buffer_read_pos..-1).include?(separator)
    rescue ArgumentError # Invalid UTF-8
      false
    end
  end
end
