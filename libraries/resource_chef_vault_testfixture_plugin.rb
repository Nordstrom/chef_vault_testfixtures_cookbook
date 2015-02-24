require 'chef/resource/lwrp_base'

class Chef
  class Resource
    # the chef_vault_testfixtures_plugin resource
    class ChefVaultTestfixturePlugin < Chef::Resource::LWRPBase
      self.resource_name = :chef_vault_testfixture_plugin
      actions :install
      default_action :install

      attribute :gem_name, kind_of: String, name_attribute: true, required: true
      attribute :install_type, kind_of: String, default: 'chef_gem', equal_to: %w(chef_gem git)
      attribute :options, kind_of: String, default: nil
      attribute :source, kind_of: String, default: nil
      attribute :version, kind_of: String, default: nil
      attribute :repository, kind_of: String, default: nil
      attribute :revision, kind_of: String, default: 'master'
    end
  end
end
