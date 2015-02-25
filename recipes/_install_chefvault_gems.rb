#
# Recipe: chef_vault_testfixtures::_install_chefvault_gems
#
# Copyright (c) 2015 Nordstrom, Inc.
#

# because most people try to load vault items in the
# compile phase, we have to install the gem at compile
# time.
at_compile_time do
  chef_gem 'chef-vault-testfixtures' do
    version node['chef_vault_testfixtures']['gem_version']
    # don't try to upgrade chef (because that pulls in Chef 12,
    # which pulls in Ohai 8, which doesn't work on Ruby 1.9.x,
    # which is what chef-client 11 packages)
    options '--conservative'
  end
end
