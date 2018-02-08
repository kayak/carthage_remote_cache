guard :test do
  watch(%r{^test/.+_tests\.rb$})
  watch('test/test_helper.rb') { 'test' }
  watch('test/fixtures.rb') { 'test' }
  watch(%r{^lib/(.+)\.rb$}) { |m| "test/#{m[1]}_tests.rb" }
end
