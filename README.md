# Event-driven HTTP Multipart Parser

This is based on https://github.com/danabr/multipart-parser, with
modifications to suit my use-case.

It currently depends on finding a `Content-Length` part header to avoid having to scan the entire body. It will raise `Cae::MultipartParser::Parser::ContentLengthUnsetError` if this header is not present.


## Usage

```ruby
parser = Cae::MultipartParser::Parser.new(boundary: boundary)

parser.parse fh do |part|
	part.on(:headers) do |headers|
		# headers is a Hash
	end
	part.on(:data) do |data|
		# data is a chunk of body data
		# this may be called multiple times
	end
	part.on(:end) do
		# part is finished, there will be no more data callbacks
	end
end
```