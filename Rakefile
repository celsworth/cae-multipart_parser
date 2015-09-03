### Specs

spec = proc do |env|
	env.each{|k,v| ENV[k] = v}
	sh "#{FileUtils::RUBY} -rubygems -I lib -e 'ARGV.each{|f| require f}' ./spec/*_spec.rb"
	env.each{|k,v| ENV.delete(k) }
end

desc "Run specs"
task "spec" do
	spec.call({})
end

task :default => :spec
