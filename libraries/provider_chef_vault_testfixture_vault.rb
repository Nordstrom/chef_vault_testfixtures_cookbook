require 'chef/provider/lwrp_base'

class Chef
  class Provider
    # provides the chef_vault_testfixtures_vault resource
    class ChefVaultTestfixtureVault < Chef::Provider::LWRPBase
      include Chef::DSL::IncludeRecipe

      use_inline_resources if defined?(use_inline_resources)

      def whyrun_supported?
        true
      end

      # dispatches to install_chef_gem or install_git based on
      # the install_type attribute of the resource
      action :create do
        include_recipe 'chef_vault_testfixtures::_install_chefvault_gems'
        require 'chef-vault/test_fixtures'

        # make sure we have a plugin by that name
        plugins = ChefVault::TestFixtures.plugins
        unless plugins.key?(new_resource.plugin.to_sym)
          fail ArgumentError, 'chef-vault-testfixtures plugin ' \
            "#{new_resource.plugin} not found"
        end

        # instantate the plugin object
        pluginclass = plugins[new_resource.plugin.to_sym]
        plugin = pluginclass.new

        # iterate over each of the public methods, creating
        # a vault for each
        pluginclass.instance_methods(false).each do |item|
          build_vault(new_resource.plugin, item, plugin)
        end
      end

      private

      def build_vault(vaultname, itemname, plugin)
        vi = ChefVault::Item.new(vaultname, itemname.to_s)
        plugin.send(itemname).each { |k, v| vi[k] = v }
        vi.clients('*:*')
        vi.save
      end
    end
  end
end
