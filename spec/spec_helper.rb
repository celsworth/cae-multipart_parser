# vim: et sw=2 ts=2 sts=2

$:.unshift(File.expand_path("../lib", File.dirname(__FILE__)))

require "rubygems"

gem 'minitest'
require "minitest/autorun"

require 'cae/multipart_parser'

require 'securerandom'
require 'net/http/post/multipart'


# create a mock boundary
def generate_boundary
  ("-" * 24) + SecureRandom.random_bytes(8).unpack('H*').first
end

# create a multipart body out of the given array
def generate_body(boundary, arr)
  parts = {}
  arr.each_with_index do |part, idx|
    fileno = "file#{idx}"
    parts[fileno] = UploadIO.new(StringIO.new(part), fileno, 'application/binary')
  end

  req = Net::HTTP::Post::Multipart.new '/', parts, {}, boundary
  req.body_stream.read
end
