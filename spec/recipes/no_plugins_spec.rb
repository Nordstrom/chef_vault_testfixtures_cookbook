RSpec.describe 'chef_vault_testfixtures::default - no plugins' do
  include_context 'chef run'
  include_context 'stub chef vault network'
  include_context 'clear plugins'
  include_examples 'standard chef run expectations'

  it "doesn't install any plugins" do
    expect(
      chef_run.find_resources(:chef_vault_testfixture_plugin)
    ).to be_empty
  end

  it "doesn't create any vaults" do
    # we can't really un-require the support plugins, so we just
    # prevent load_plugins from doing its thing
    expect(ChefVault::TestFixtures).to receive(:plugins).and_return({})
    expect(ChefVault::Item).not_to receive(:new)
    expect(
      chef_run.find_resources(:chef_vault_testfixture_vault)
    ).to be_empty
  end
end
