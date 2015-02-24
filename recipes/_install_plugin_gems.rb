#
# Recipe: chef_vault_testfixtures::_install_plugin_gems
#
# Copyright (c) 2015 Nordstrom, Inc.
#

node['chef_vault_testfixtures']['install_gems'].each do |gemname, geminfo|
  at_compile_time do
    chef_vault_testfixture_plugin gemname do
      geminfo.each do |k, v|
        send k.to_sym, v
      end
    end
  end
end
