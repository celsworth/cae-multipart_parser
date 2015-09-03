# vim: et sw=2 ts=2 sts=2

$:.unshift(File.expand_path("../lib", File.dirname(__FILE__)))

require "rubygems"

gem 'minitest'
require "minitest/autorun"

require 'securerandom'

require 'cae/multipart_parser'

# create a mock boundary
def generate_boundary
  ("-" * 24) + SecureRandom.random_bytes(8).unpack('H*').first
end

# create a multipart body out of the given array
def generate_body(boundary, arr)

  str = ''
  arr.each do |p|
    str << "--" + boundary + "\r\n"
    str << "Content-Length: #{p.length}\r\n"
    str << "\r\n"
    str << p
    str << "\r\n"
  end

  str << "--" + boundary + "--\r\n"

end
