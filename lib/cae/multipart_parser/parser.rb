# vim: et sw=2 ts=2 sts=2

module Cae
  module MultipartParser
    class Parser

      CR = "\r".freeze
      LF = "\n".freeze
      DASH = "-".freeze

      BOUNDARY_PREFIX = (CR + LF + DASH + DASH).freeze

      ContentLengthUnsetError = Class.new(StandardError)

      ParseError = Class.new(StandardError)

      attr_accessor :read_buffer_size

      def initialize(opts = {})
        # remember offsets into our state in between calls
        @index = 0

        @state = :start

        # default 2MB read buffer
        @read_buffer_size = 2 * 1024 * 1024

        @boundary = BOUNDARY_PREFIX + opts[:boundary]
        @boundary_length = @boundary.length
      end

      # Parse data from the IO +io+
      #
      # @return [Integer] the number of bytes parsed.
      def parse(io)
        parsed = 0

        buffer = String.new
        while io.read(@read_buffer_size, buffer)
          length = buffer.length
          i = 0
          data_start = 0

          while i < length
            c = buffer[i]

            #p "state=#{@state} index=#{@index} chars=#{buffer[i, 40]}"

            case @state
            when :start
              if @index == @boundary_length - 2
                break unless c == CR
                @index += 1
              elsif @index == @boundary_length - 1
                break unless c == LF
                # reached end of boundary, we're into the first part
                @state = :headers_start
              else
                # there is no leading \r\n on the first boundary, hence index+2
                break unless c == @boundary[@index + 2] # Unexpected character
                @index += 1
              end

            when :headers_start
              @part = Part.new
              @state = :headers
              @index = 0
              @headers = ''
              next # keep i pointing at current char for :headers

            when :headers
              if (c == CR && @index == 0) || (c == LF && @index == 1)
                # keep \r\n to split on later
                @headers << c
                @index += 1
              elsif c == CR && @index == 2
                # don't keep final \r, update state to check for final \n
                @state = :headers_almost_done
              else
                # normal header char, reset index and keep char
                @headers << c
                @index = 0
              end

            when :headers_almost_done
              break unless c == LF # Unexpected character
              @state = :part_start

            when :part_start
              # this must populate #content_length
              @part.parse_header_str @headers

              raise ContentLengthUnsetError if @part.content_length == 0

              chunk_remaining = length - data_start
              cb_len = @part.content_length > chunk_remaining ? chunk_remaining : @part.content_length
              @part.body = Part::Body.new(io, @part.content_length, buffer[i, cb_len])
              yield @part

              i += cb_len

              @index = 0
              @state = :boundary
              next # we've bumped i already, don't increment it

            when :boundary
              break unless c == @boundary[@index] # unexpected character
              @index += 1
              @state = :boundary_almost_done if @index == @boundary_length

            when :boundary_almost_done
              # work out whether this is a part boundary or the final boundary
              if c == CR
                @state = :boundary_part_almost_done
              elsif c == DASH
                @state = :boundary_last_almost_done
              else
                break # unexpected character, this isn't a boundary after all
              end
              @index += 1

            when :boundary_part_almost_done
              # final character of an inter-part boundary must be LF
              break unless c == LF # unexpected character
              @state = :headers_start

            when :boundary_last_almost_done
              # final character of final boundary must be -
              break unless c == DASH # unexpected character
              @state = :end

            end # case

            i += 1

          end # while

          if i != length
            raise ParseError, "unexpected char at char #{parsed+i} (#{c.inspect})"
          end

          parsed += length

        end # while

        parsed
      end

    end
  end
end
