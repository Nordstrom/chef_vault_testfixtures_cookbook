require 'json'
require 'chef-vault'

vi_test = ChefVault::Item.load('bar', 'test')
vi_prod = ChefVault::Item.load('bar', 'prod')

file '/tmp/kitchen/bar_test.secret' do
  content vi_test.to_json
end

file '/tmp/kitchen/bar_prod.secret' do
  content vi_prod.to_json
end
