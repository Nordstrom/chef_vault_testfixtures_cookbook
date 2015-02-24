if defined?(ChefSpec)
  # default
  def create_chef_vault_testfixtures(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:chef_vault_testfixtures, :create, resource_name)
  end

  # vault
  def create_chef_vault_testfixture_vault(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:chef_vault_testfixture_vault, :create, resource_name)
  end

  # plugin
  def install_chef_vault_testfixture_plugin(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:chef_vault_testfixture_plugin, :install, resource_name)
  end
end
