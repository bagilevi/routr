guard 'rspec', :all_on_start => true, :all_after_pass => true do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/routr/(.+)\.rb$})     { |m| "spec/unit/#{m[1]}_spec.rb" }
  watch(%r{^lib/routr\.rb$})     { |m| "spec/integration" }
  watch(%r{^lib/routr/interface\.rb$})     { |m| "spec/integration" }
end


