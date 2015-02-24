RSpec.describe 'chef_vault_testfixtures::default - git plugin' do
  include_context 'stub chef vault network'
  include_context 'chef run' do
    let(:chef_run_attrs) do
      {
        'install_gems' => {
          'foo' => {
            'install_type' => 'git',
            'repository' => 'http://foo.example.com/foo.git'
          },
          'bar' => {
            'install_type' => 'git',
            'repository' => 'http://foo.example.com/bar.git',
            'revision' => 'my_fix'
          }
        }
      }
    end
  end
  include_examples 'standard chef run expectations'

  it 'installs the foo plugin using git' do
    expect(chef_run).to(
      install_chef_vault_testfixture_plugin('foo').with(install_type: 'git')
    )
    expect(chef_run).to checkout_git(
      ::File.join(Chef::Config[:file_cache_path], 'foo')
    )
    expect(chef_run).to run_ruby_block('install vault plugin foo')
  end

  it 'installs the bar plugin using git' do
    expect(chef_run).to(
      install_chef_vault_testfixture_plugin('bar').with(install_type: 'git')
    )
    expect(chef_run).to checkout_git(
      ::File.join(Chef::Config[:file_cache_path], 'bar')
    ).with(revision: 'my_fix')
    expect(chef_run).to run_ruby_block('install vault plugin bar')
  end
end
