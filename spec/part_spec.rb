# vim: et sw=2 ts=2 sts=2

require File.expand_path("spec_helper", File.dirname(__FILE__))

describe Cae::MultipartParser::Part do
  let(:part) { Cae::MultipartParser::Part.new }

  describe '#parse_header_str' do
    it "parses a simple input" do
      input = "Content-Type: text/html"
      part.parse_header_str(input).must_equal({
        'Content-Type' => 'text/html'
      })
    end

    it "ignores trailing CRLF" do
      input = "Content-Type: text/html\r\n"
      part.parse_header_str(input).must_equal({
        'Content-Type' => 'text/html'
      })
    end

    it "parses multiple lines" do
      input = "Content-Type: text/html\r\nContent-Length: 100"
      part.parse_header_str(input).must_equal({
        'Content-Type' => 'text/html',
        'Content-Length' => '100'
      })
    end

    it "parses multiline headers" do
      input = "Content-Type: multipart/form-data;\r\n\tboundary=foo"
      part.parse_header_str(input).must_equal({
        'Content-Type' => 'multipart/form-data; boundary=foo'
      })
    end

    it "parses multiple multiline headers" do
      input = "Content-Type: multipart/form-data;\r\n\tboundary=foo\r\nContent-Type2: multipart/form-data;\r\n\tboundary=bar"
      part.parse_header_str(input).must_equal({
        'Content-Type' => 'multipart/form-data; boundary=foo',
        'Content-Type2' => 'multipart/form-data; boundary=bar'
      })
    end
  end

  describe '#content_length' do
    it "considers Content-Length to be zero if unset" do
      input = "Content-Type: text/html"
      part.parse_header_str(input)
      part.content_length.must_equal 0
    end

    it "exposes Content-Length if present in headers" do
      input = "Content-Type: text/html\r\nContent-Length: 100"
      part.parse_header_str(input)
      part.content_length.must_equal 100
    end
  end

  describe "#callback" do
    it "ignores an unregistered callback type" do
      part.callback(:unregistered).must_equal nil
    end

    it "calls a registered callback type" do
      foo = 0
      cb = ->(arg){ foo = arg }
      part.on(:registered, &cb)
      part.callback(:registered, 1)
      foo.must_equal 1
    end

    it "defaults to a nil arg" do
      foo = true
      cb = ->(arg){ foo = arg }
      part.on(:registered, &cb)
      part.callback(:registered)
      foo.must_equal nil
    end
  end
end
