%w(foo bar).each do |plugin|
  at_compile_time do
    cookbook_file "/tmp/kitchen/chef-vault-testfixture-plugin-#{plugin}.tar.gz"
    bash "extract plugin repo tarball - #{plugin}" do
      cwd '/tmp/kitchen'
      code "tar zxf chef-vault-testfixture-plugin-#{plugin}.tar.gz"
    end
  end
end
