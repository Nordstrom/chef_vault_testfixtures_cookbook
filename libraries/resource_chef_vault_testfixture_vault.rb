require 'chef/resource/lwrp_base'

class Chef
  class Resource
    # the chef_vault_testfixtures_vault resource
    class ChefVaultTestfixtureVault < Chef::Resource::LWRPBase
      self.resource_name = :chef_vault_testfixture_vault
      actions :create
      default_action :create

      attribute :plugin, kind_of: String, name_attribute: true, required: true
    end
  end
end
