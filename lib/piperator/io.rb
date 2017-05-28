require 'English'

module Piperator
  # Pseudo I/O on Enumerators
  class IO
    FLUSH_THRESHOLD = 128 * 1028 # 128KiB

    attr_reader :eof

    def initialize(enumerator, flush_threshold: FLUSH_THRESHOLD)
      @enumerator = enumerator
      @flush_threshold = flush_threshold
      @io = StringIO.new
      @buffer_start_pos = 0
      @io_read_pos = 0
      @eof = false
    end

    alias eof? eof

    # Return the first bytes of the buffer without marking the buffer as read.
    def peek(bytes)
      while @eof == false && readable_bytes < (bytes || 1)
        @io.write(@enumerator.next)
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
          @io.write(@enumerator.next)
        rescue StopIteration
          @eof = true
          nil
        end
      end
      read_with { @io.gets(separator) }
    end

    # Flush internal buffer until the last unread byte
    def flush
      if @io.pos == @io_read_pos
        initialize_buffer
      else
        @io.pos = @io_read_pos
        initialize_buffer(@io.read)
      end
    end

    # Reads length bytes from the I/O stream.
    #
    # @param length [Integer] number of bytes to read
    # @return String
    def read(length = nil)
      return @enumerator.next if length.nil? && readable_bytes.zero?
      @io.write(@enumerator.next) while !@eof && readable_bytes < (length || 1)
      read_with { @io.read(length) }
    rescue StopIteration
      @eof = true
      read_with { @io.read(length) } if readable_bytes > 0
    end

    # Current buffer size - including non-freed read content
    #
    # @return [Integer] number of bytes stored in buffer
    def used
      @io.size
    end

    private

    def readable_bytes
      @io.pos - @io_read_pos
    end

    def read_with
      pos = @io.pos
      @io.pos = @io_read_pos

      yield.tap do |data|
        @io_read_pos += data.bytesize if data
        @io.pos = pos
        flush if flush?
      end
    end

    def peek_buffer(bytes)
      @io.string.byteslice(@io_read_pos...@io_read_pos + bytes)
    end

    def flush?
      @io.pos == @io_read_pos || @io.pos > @flush_threshold
    end

    def initialize_buffer(data = nil)
      @io_read_pos = 0
      @buffer_start_pos += @io.pos if @io
      @io = StringIO.new
      @io.write(data) if data
    end

    def contains_line?(separator = $INPUT_RECORD_SEPARATOR)
      return true if @eof
      @io.string.byteslice(@io_read_pos..-1).include?(separator)
    rescue ArgumentError # Invalid UTF-8
      false
    end
  end
end
