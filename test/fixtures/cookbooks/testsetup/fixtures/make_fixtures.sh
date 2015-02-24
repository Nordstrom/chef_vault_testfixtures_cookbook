#!/bin/bash

# creates rubygem and git repo tarball versions of the plugins to use
# during integration testing of the chef_vault_testfixtures cookbook

rm -f files/default/*.gem
rm -f files/default/*.tar.gz

for plugin in foo bar
do
  pushd chef-vault-testfixture-plugin-$plugin
  gem build chef-vault-testfixture-plugin-$plugin.gemspec
  mv *.gem ../../files/default
  git init
  git add .
  git commit -m 'initial commit'
  git branch my_fix_to_$plugin master
  pushd ..
  tar zcf ../files/default/chef-vault-testfixture-plugin-$plugin.tar.gz chef-vault-testfixture-plugin-$plugin
  popd
  rm -rf .git
  popd
done
