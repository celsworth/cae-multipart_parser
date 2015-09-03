# vim: et sw=2 ts=2 sts=2
module Cae
  module MultipartParser
    class Part

      attr_reader :headers

      def initialize
        @callbacks = {}
        @headers = {}
      end

      def parse_header_str(str)
        # munge multiline headers back into one line.
        str = str.gsub /\r\n\s+/, ' '

        # split header string into a hash
        str.split(/\r\n/).each do |h|
          key, value = h.split ':'
          @headers[key] = value.lstrip
        end
        @headers
      end

      def content_length
        @headers['Content-Length'].to_i
      end

      def on(event, &callback)
        @callbacks[event] = callback
      end

      # Parser will call :headers, :data, :end
      def callback(event, arg = nil)
        @callbacks[event].call(arg) if @callbacks.has_key?(event)
      end

    end
  end
end
