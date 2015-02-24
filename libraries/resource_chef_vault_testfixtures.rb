require 'chef/resource/lwrp_base'

class Chef
  class Resource
    # the chef_vault_testfixtures_plugin resource
    class ChefVaultTestfixtures < Chef::Resource::LWRPBase
      self.resource_name = :chef_vault_testfixtures
      actions :create
      default_action :create

      attribute :name, kind_of: String, name_attribute: true, default: 'all'
      attribute :plugins, kind_of: Array
      attribute :disregard_plugin, kind_of: Array
    end
  end
end
