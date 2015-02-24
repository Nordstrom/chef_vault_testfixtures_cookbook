#
# Recipe: chef_vault_testfixtures::_create_vaults
#
# Copyright (c) 2015 Nordstrom, Inc.
#

at_compile_time do
  chef_vault_testfixtures 'all' do
    plugins node['chef_vault_testfixtures']['plugins']
    disregard_plugin node['chef_vault_testfixtures']['disregard_plugin']
  end
end
