# vim: et sw=2 ts=2 sts=2

require File.expand_path("spec_helper", File.dirname(__FILE__))

def read_all(fh, chunksize, outbuf = nil)
  str = String.new
  outbuf = String.new
  while fh.read(chunksize, outbuf)
    str << outbuf
  end
  str
end

describe Cae::MultipartParser::Part::Body do
  let(:fh_data) { '12345' }
  let(:initial_buffer) { nil }
  let(:size_limit) { 5 }
  let(:expected) { ((initial_buffer || '') + fh_data)[0, size_limit] }
  let(:fh) { StringIO.new fh_data }
  let(:body) do
    Cae::MultipartParser::Part::Body.new(fh, size_limit, initial_buffer)
  end

  (1..15).each do |chunksize|
    it "should work with read chunk size #{chunksize}" do
      read_all(body, chunksize).must_equal expected
    end
  end

  describe "with an initial buffer" do
    let(:initial_buffer) { 'abcde' }
    let(:size_limit) { 10 }

    (1..15).each do |chunksize|
      it "should work with read chunk size #{chunksize}" do
        read_all(body, chunksize).must_equal expected
      end
    end

    it "should not reallocate if passed an outbuf" do
      outbuf = String.new
      refute_changes(->{outbuf.object_id}) do
        while body.read(1, outbuf)
          # no-op
        end
      end
    end

    it "should return nil when empty" do
      read_all(body, size_limit) # empty the "file"
      body.read(1).must_equal nil
    end

    describe "with a shorter size_limit than data available" do
      let(:size_limit) { 5 }
      it "should stop returning data when size_limit is hit" do
        read_all(body, 1).must_equal expected
      end

      it "should return nil when 'empty'" do
        read_all(body, size_limit) # empty the "file"
        body.read(1).must_equal nil
      end
    end

  end


end
