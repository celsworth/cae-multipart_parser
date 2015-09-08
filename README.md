# Event-driven HTTP Multipart Parser

This is based on https://github.com/danabr/multipart-parser, with modifications to suit my use-case.

It currently depends on finding a `Content-Length` part header to avoid having to scan the entire body. It will raise `Cae::MultipartParser::Parser::ContentLengthUnsetError` if this header is not present.


## Usage

```ruby
parser = Cae::MultipartParser::Parser.new(boundary: boundary)

parser.parse fh do |part|
	# part.headers and part.content_length should be set now
	# headers are underscored and uppercased:
	if part.headers['CONTENT_TYPE'] == 'text/html'
		# ...
	end

	# content_length is an integer:
	if part.content_length < 1024
		# ...
	end

	while part.body.read(chunksize, buf)
		# buf contains up to chunksize bytes of data.
		# Do not assume if less than chunksize is returned, you're done,
		# for internal as-yet-to-be-fixed reasons.
		# Only stop when #read returns nil. Note that #read is NOT IO#read,
		# but is mostly compatible.
	end

	# all the part body has now been read
end
```
