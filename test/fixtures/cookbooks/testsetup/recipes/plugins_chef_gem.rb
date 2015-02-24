%w(foo bar).each do |plugin|
  at_compile_time do
    cookbook_file "/tmp/kitchen/chef-vault-testfixture-plugin-#{plugin}-0.1.0.gem"
  end
end
