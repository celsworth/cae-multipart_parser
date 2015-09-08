# vim: et sw=2 ts=2 sts=2

require 'cae/multipart_parser/part/body'

module Cae
  module MultipartParser
    class Part

      attr_reader :headers
      attr_accessor :body

      def initialize
        @callbacks = {}
        @headers = {}
        @body = nil
      end

      def parse_header_str(str)
        # Munge multiline headers back into one line.
        str = str.gsub /\r\n\s+/, ' '

        # Split header string into a hash. Returns the initial hash.
        str.split(/\r\n/).each_with_object(@headers) do |line, headers|
          key, value = line.split ':'

          # normalize Content-Length -> CONTENT_LENGTH
          key.upcase!
          key.tr! '-', '_'

          headers[key] = value.lstrip
        end
      end

      def content_length
        @headers['CONTENT_LENGTH'].to_i
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
