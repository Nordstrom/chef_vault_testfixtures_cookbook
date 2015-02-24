RSpec.describe 'chef_vault_testfixtures::default - all plugins' do
  include_context 'chef run'
  include_context 'stub chef vault network'
  include_context 'clear plugins'
  include_examples 'standard chef run expectations'

  it 'creates the foo and bar vaults' do
    expect(ChefVault::Item).to receive(:new).with('foo', 'test').and_call_original
    expect(ChefVault::Item).to receive(:new).with('bar', 'test').and_call_original
    expect(ChefVault::Item).to receive(:new).with('bar', 'prod').and_call_original
    expect(chef_run).to create_chef_vault_testfixture_vault('foo')
    expect(chef_run).to create_chef_vault_testfixture_vault('bar')
  end
end
