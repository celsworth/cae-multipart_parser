# vim: et sw=2 ts=2 sts=2

require File.expand_path("spec_helper", File.dirname(__FILE__))

boundary = generate_boundary

describe Cae::MultipartParser::Parser do
  let(:parser) do
    Cae::MultipartParser::Parser.new(boundary: boundary)
  end

  it "calls the :headers callback with a hash" do
    body = SecureRandom.random_bytes(1024) # random data
    fh = StringIO.new generate_body(boundary, [body])

    headers = nil
    parser.parse fh do |part|
      part.on(:headers){|h| headers = h }
    end
    headers.must_be_kind_of Hash
  end

  it "calls the :data callback with the original data" do
    body = SecureRandom.random_bytes(1024 * 1024) # 1MB of random data
    fh = StringIO.new generate_body(boundary, [body])
    ret = ''
    parser.parse fh do |part|
      part.on(:data){|data| ret << data }
    end

    ret.must_equal body
  end

  it "calls the :end callback after the part is done" do
    body = SecureRandom.random_bytes(1024) # random data
    fh = StringIO.new generate_body(boundary, [body])
    done = 0
    parser.parse fh do |part|
      part.on(:end){ done += 1 }
    end

    done.must_equal 1
  end

  it "calls callbacks after each part is done" do
    body = SecureRandom.random_bytes(1024) # random data
    fh = StringIO.new generate_body(boundary, [body, body])
    headers, done = 0, 0
    parser.parse fh do |part|
      part.on(:headers){ headers += 1 }
      part.on(:end){ done += 1 }
    end

    headers.must_equal 2
    done.must_equal 2
  end
end
