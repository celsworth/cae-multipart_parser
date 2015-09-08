# vim: et sw=2 ts=2 sts=2

require File.expand_path("spec_helper", File.dirname(__FILE__))

describe Cae::MultipartParser::Parser do
  let(:boundary) do
    # create a random boundary
    ("-" * 24) + SecureRandom.random_bytes(8).unpack('H*').first
  end

  let(:parser) do
    Cae::MultipartParser::Parser.new(boundary: boundary)
  end

  describe "#parse" do
    it "raises ContentLengthUnsetError on missing Content-Length" do
      part = SecureRandom.random_bytes(1024) # random data
      body = generate_body(boundary, [part])
      fh = StringIO.new body.sub('Content-Length', 'Not-Content-Length')
      proc{ parser.parse(fh){ } }.must_raise Cae::MultipartParser::Parser::ContentLengthUnsetError
    end

    it "raises ParseError on a partial message" do
      part = SecureRandom.random_bytes(1024) # random data
      body = generate_body(boundary, [part])
      fh = StringIO.new body[0, 500]
      proc{ parser.parse(fh){ } }.must_raise Cae::MultipartParser::Parser::ParseError
    end

    it "returns the number of bytes parsed" do
      part = SecureRandom.random_bytes(1024) # random data
      body = generate_body(boundary, [part])
      fh = StringIO.new body

      r = parser.parse(fh){ }
      r.must_equal body.length
    end

    it "sets part#headers" do
      part = SecureRandom.random_bytes(1024) # random data
      fh = StringIO.new generate_body(boundary, [part])

      parser.parse(fh){|part| part.headers.must_be_kind_of Hash }
    end

    it "passes the original data to the part#body handle" do
      part = SecureRandom.random_bytes(1024 * 1024) # 1MB of random data
      fh = StringIO.new generate_body(boundary, [part])
      ret = ''
      parser.parse fh do |part|
        part.body.must_be_kind_of Cae::MultipartParser::Part::Body
        while x = part.body.read(1024)
          ret << x
        end
      end
      ret.must_equal part
    end

    it "yields for each part" do
      part = SecureRandom.random_bytes(1024) # random data
      parts = [part, part]
      fh = StringIO.new generate_body(boundary, parts)
      done = 0
      parser.parse(fh){|part| done += 1 }
      done.must_equal parts.count
    end
  end
end
