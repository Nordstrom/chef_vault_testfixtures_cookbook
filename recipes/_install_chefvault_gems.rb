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
    version '~> 0.1'
  end
end
