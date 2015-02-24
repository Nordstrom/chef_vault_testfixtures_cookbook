RSpec.describe 'chef_vault_testfixtures::default - chef_gem plugin' do
  include_context 'stub chef vault network'
  include_context 'chef run' do
    let(:chef_run_attrs) do
      { 'install_gems' => { 'foo' => {}, 'bar' => {} } }
    end
  end
  include_examples 'standard chef run expectations'

  it 'installs the foo and bar plugins using chef_gem' do
    %w(foo bar).each do |gem|
      expect(chef_run).to(
        install_chef_vault_testfixture_plugin(gem).with(install_type: 'chef_gem')
      )
      expect(chef_run).to install_chef_gem(gem)
    end
  end
end
