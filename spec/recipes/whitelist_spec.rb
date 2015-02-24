RSpec.describe 'chef_vault_testfixtures::default - foo plugin whitelist' do
  include_context 'clear plugins'
  include_context 'stub chef vault network'
  include_context 'chef run' do
    let(:chef_run_attrs) do
      { 'plugins' => %w(foo) }
    end
  end
  include_examples 'standard chef run expectations'

  it 'only creates the foo vault' do
    expect(ChefVault::Item).to receive(:new).with('foo', 'test').and_call_original
    expect(ChefVault::Item).not_to receive(:new).with('bar', 'test')
    expect(ChefVault::Item).not_to receive(:new).with('bar', 'prod')
    expect(chef_run).to create_chef_vault_testfixture_vault('foo')
    expect(chef_run).not_to create_chef_vault_testfixture_vault('bar')
  end
end

RSpec.describe 'chef_vault_testfixtures::default - bar plugin whitelist' do
  include_context 'stub chef vault network'
  include_context 'clear plugins'
  include_context 'chef run' do
    let(:chef_run_attrs) do
      { 'plugins' => %w(bar) }
    end
  end
  include_examples 'standard chef run expectations'

  it 'only creates the bar vault' do
    expect(ChefVault::Item).to receive(:new).with('bar', 'test').and_call_original
    expect(ChefVault::Item).to receive(:new).with('bar', 'prod').and_call_original
    expect(ChefVault::Item).not_to receive(:new).with('foo', 'test')
    expect(chef_run).to create_chef_vault_testfixture_vault('bar')
    expect(chef_run).not_to create_chef_vault_testfixture_vault('foo')
  end
end

RSpec.describe 'chef_vault_testfixtures::default - whitelist all' do
  include_context 'stub chef vault network'
  include_context 'clear plugins'
  include_context 'chef run' do
    let(:chef_run_attrs) do
      { 'plugins' => %w(foo bar) }
    end
  end
  include_examples 'standard chef run expectations'

  it 'creates the foo and bar vaults' do
    expect(ChefVault::Item).to receive(:new).with('foo', 'test').and_call_original
    expect(ChefVault::Item).to receive(:new).with('bar', 'test').and_call_original
    expect(ChefVault::Item).to receive(:new).with('bar', 'prod').and_call_original
    expect(chef_run).to create_chef_vault_testfixture_vault('foo')
    expect(chef_run).to create_chef_vault_testfixture_vault('bar')
  end
end
