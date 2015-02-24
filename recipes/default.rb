#
# Recipe: chef_vault_testfixtures::default
#
# Copyright (c) 2015 Nordstrom, Inc.
#

include_recipe "#{cookbook_name}::_install_chefvault_gems"
include_recipe "#{cookbook_name}::_install_plugin_gems"
include_recipe "#{cookbook_name}::_create_vaults"
