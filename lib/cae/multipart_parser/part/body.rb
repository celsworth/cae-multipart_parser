# vim: et sw=2 ts=2 sts=2
module Cae
  module MultipartParser
    class Part
      class Body

        def initialize(fh, read_limit, read_buffer = nil)
          # Backing filehandle
          @fh = fh

          # After we've read this amount, act like the backing filehandle is empty
          @read_limit = read_limit

          # If anything is in this, we'll return it on the first read()
          @read_buffer = read_buffer
        end

        def read(length, outbuf = nil)
          # Check we're not trying to read more bytes than are available
          length = @read_limit > length ? length : @read_limit

          # Early nil return if there's nothing available. This technically
          # breaks compatibility with IO#read, but I don't care.
          # (IO#read returns an empty string if passed length is 0; we'll return nil)
          return nil if length == 0

          # if there's anything in @read_buffer, return it before doing a real read
          if @read_buffer
            # initialise outbuf if it wasn't passed in.
            outbuf ||= String.new

            # copy contents into outbuf, being careful NOT to change the object_id
            outbuf.clear
            outbuf << @read_buffer[0, length]

            # advance buffer pointer; if there's none left, @read_buffer will be nil
            @read_limit -= outbuf.length
            @read_buffer = @read_buffer[length, @read_limit]

            return outbuf
          end

          @fh.read(length, outbuf).tap {|o| @read_limit -= o.length if o }
        end

      end
    end
  end
end
