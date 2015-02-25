#
# Cookbook chef_vault_testfixtures
#
# Copyright (c) 2015 Nordstrom, Inc.
#

# set this to constrain the version of chef-vault that the cookbook
# installs.  If not set, the latest copy on Rubygems will be used
# default['chef_vault_testfixtures']['chef_vault_version'] = '2.5.0'

# override this to only load certain plugins
# an empty list of plugins means 'load everything you find'
default['chef_vault_testfixtures']['plugins'] = []

# override this to blacklist certain vaults
default['chef_vault_testfixtures']['disregard_plugin'] = []

# overrride this to install plugin gems before creating the vaults
default['chef_vault_testfixtures']['install_gems'] = {}

# override this to change what version of the chef-vault-testfixtures
# gem is installed by the cookbook
default['chef_vault_testfixtures']['gem_version'] = '~> 0.2'

# example: install using chef_gem from Rubygems or an internal Geminabox
# default['chef_vault_testfixtures']['install_gems'].tap |o|
#   o['my_vault_testfixtures'].tap |gem|
#     gem['install_type'] = 'chef_gem' # this is the default
#     gem['options'] = '--clear-sources --no-rdoc --no-ri --source https://gems.mycompany.int'
#   end
# end

# example: install by cloning a git repo and running 'gem build' then 'gem install'
# default['chef_vault_testfixtures']['install_gems'].tap |o|
#   o['my_vault_testfixtures'].tap |gem|
#     gem['install_type'] = 'git'
#     gem['url'] = 'https://git.mycompany.int/scm/gems/my_vault_testfixtures.git'
#     gem['ref'] = 'v1.2.3'
#   end
# end
