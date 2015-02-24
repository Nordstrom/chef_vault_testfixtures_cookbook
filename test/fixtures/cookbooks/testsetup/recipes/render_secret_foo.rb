require 'json'
require 'chef-vault'

vi = ChefVault::Item.load('foo', 'test')

file '/tmp/kitchen/foo_test.secret' do
  content vi.to_json
end
