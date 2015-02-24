require 'chefspec'
require 'chefspec/berkshelf'

require 'chef-vault'
require 'chef-vault/test_fixtures'

# pull in some fixture plugins
require 'support/chef_vault/test_fixtures/foo'
require 'support/chef_vault/test_fixtures/bar'

ChefSpec::Coverage.start! if ENV['COVERAGE']

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.disable_monkey_patching!
  config.order = :random
  Kernel.srand config.seed
end

# LittlePlugger doesn't expect to have its inclusion/exclusion
# lists reset in a single process, so we have to monkeypatch
# in some testing functionality
module LittlePlugger
  module ClassMethods
    def clear_plugins
      @plugin_names = []
      @disregard_plugin = []
      @loaded = {}
    end
  end
end

# shared helper to ensure that we never do network ops in chef-vault
RSpec.shared_context 'stub chef vault network' do
  before do
    allow_any_instance_of(ChefVault::Item)
      .to receive(:clients).with(String)
    allow_any_instance_of(ChefVault::Item)
      .to receive(:save)
    allow_any_instance_of(ChefVault::Item)
      .to receive(:[]=).with(String, Object)
  end
end

# shared helper to clear the plugin white/black lists
RSpec.shared_context 'clear plugins' do
  before do
    # clear the plugin white/black lists
    ChefVault::TestFixtures.clear_plugins
  end
end

# shared helper for a chef run.  Allows a block to
# set the node attributes by defining chef_run_attrs method
RSpec.shared_context 'chef run' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      step_into: %w(
        chef_vault_testfixtures
        chef_vault_testfixture_vault
        chef_vault_testfixture_plugin
      ),
      file_cache_path: '/var/chef/cache'
    ) do |node|
      if respond_to?(:chef_run_attrs)
        chef_run_attrs.each do |k, v|
          node.set['chef_vault_testfixtures'][k] = v
        end
      end
    end.converge('chef_vault_testfixtures::default')
  end
end

# shared examples for normal expectations - a clean run that includes a
# chef_vault_testfixtures resource
RSpec.shared_examples 'standard chef run expectations' do
  it 'converges successfully' do
    expect(chef_run).to include_recipe('chef_vault_testfixtures::default')
  end

  it 'declares a set of fixture vaults' do
    expect(chef_run).to create_chef_vault_testfixtures('all')
  end
end
