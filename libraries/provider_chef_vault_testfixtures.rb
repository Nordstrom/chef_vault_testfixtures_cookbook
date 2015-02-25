require 'chef/provider/lwrp_base'

class Chef
  class Provider
    # provides the chef_vault_testfixtures_plugin resource
    class ChefVaultTestfixtures < Chef::Provider::LWRPBase
      include Chef::DSL::IncludeRecipe
      include ChefVaultTestFixtures::AtCompileTime

      use_inline_resources if defined?(use_inline_resources)

      def whyrun_supported?
        true
      end

      # dispatches to install_chef_gem or install_git based on
      # the install_type attribute of the resource
      action :create do
        include_recipe 'chef_vault_testfixtures::_install_chefvault_gems'
        require 'chef-vault/test_fixtures'

        # set the plugin white/black lists from our attributes
        new_resource.plugins.each do |plugin|
          ChefVault::TestFixtures.plugin(plugin)
        end
        new_resource.disregard_plugin.each do |plugin|
          ChefVault::TestFixtures.disregard_plugin(plugin)
        end

        # use the vault LWRP to create a vault for each plugin
        ChefVault::TestFixtures.plugins.keys.each do |vault|
          converge_by "create test fixture vault #{vault}" do
            at_compile_time do
              chef_vault_testfixture_vault vault.to_s
            end
          end
        end
      end
    end
  end
end
