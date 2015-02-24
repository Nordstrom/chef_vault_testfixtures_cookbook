# chef_vault_testfixtures

## Description

chef_vault_testfixtures is a testing-only cookbook that works with the
[chef-vault-testfixtures](https://rubygems.org/gems/chef-vault-testfixtures)
gem to make integration testing of a cookbook that uses chef-vault easier.

The gem provides an RSpec shared context to give you automagical stubs
for your unit tests.  You create plugins with valid sample data for the
vaults you use in your cookbook, and when your cookbook requests data
from the vault the stub provides the sample data instead.

When integration testing a cookbook with [Test Kitchen](http://kitchen.ci/),
you can't use stubs, so this cookbook creates real encrypted vaults using
the same sample data.  The secrets are encrypted during the compile phase,
using the public key of the dynamically created node under test.

If you've ever had to create pre-encrypted secrets in
`test/integration/data_bags/vaultname/itemname.json` along with a private key
in `test/integration/clients/username.pem`, or twisted your setup to
fall back to an unencrypted data bag only when running under test, then
this cookbook is for you.

## Usage

***THIS COOKBOOK SHOULD NEVER BE IN A NODE'S RUN LIST!***

***THIS COOKBOOK SHOULD NEVER BE REFERENCED AS A DEPENDENCY IN metadata.rb!***

The chef_vault_testfixtures cookbook only belongs in the run-list of node
under test with Test Kitchen.  For the remainder of this document, we
assume you are using Berkshelf for cookbook dependency management.

In your `Berksfile`, add a snippet that pulls this cookbook into a test group:

    group :test do
      cookbook 'chef_vault_testfixtures', '~> 0.1'
    end

In your `.kitchen.yml`, add this cookbook to the run list for each suite:

    suites:
      - name: default
        run_list:
          - recipe[chef_vault_testfixtures]
          - recipe[your_normal_cookbook_here]

When Test Kitchen converges your cookbook, it will create a new
client identity (including a public/private keypair).  This cookbook
will then create a vaultitem for each plugin that

## Recipes

### default

The default recipe uses the chef_vault_testfixtures LWRP to create a
vault item for every plugin installed on the test box.

It installs any plugin gems described by the attributes, then iterates
over all vault plugins it can find.  Each plugin represents a vault,
and each public method in the plugin is a vault item.

## Attributes

The attributes defined by this recipe are organized under the
`node['chef_vault_testfixtures']` namespace.

Attribute | Description | Type   | Default
----------|-------------|--------|--------
plugins | List of plugins to load | Array | [] (means load all)
disregard_plugin | List of plugins to not load | Array | []
install_gems | Hash of plugin gems to install | Hash | see below

## Specifying Plugins

chef-vault-testfixtures relies on plugins containing sample data being
installed.  You provide a list of these by overriding attributes in this
cookbook in `.kitchen.yml`:

    suites:
      - name: default
        run_list:
          - recipe[chef_vault_testfixtures]
          - recipe[your_normal_cookbook_here]
        attributes:
          chef_vault_testfixtures:
            install_gems:
              my_vault_plugin_db: {}
              my_vault_plugin_rmq:
                install_type: git
                repository: https://github.com/myusername/my_chef_vault_rmq_plugin.git
                revision: my_fix_branch

The install_gems attribute is a hash.  The keys are the names of the
vault plugins to install and the values tell the cookbook how to install
the plugin.

The value is a Hash that can contain the following keys:

* **install_type**: 'chef_gem' or 'git'; if not given defaults to 'chef_gem'
* **version**: used by the 'chef_gem' install type to restrict the version of the gem to install
* **options**: used by the 'chef_gem' install type to change how the gem is installed
* **repository**: used by the 'git' install type to point to the repo to clone the gem from
* **revision**: used by the 'git' install type to checkout a specific branch or tag before building the gem

Because the install type defaults to 'chef_gem', if you are installing a plugin
from Rubygems, you can pass an empty hash, as in the `my_vault_plugin_db` example
above.

### chef_gem installation method

The install type `chef_gem` installs a plugin using the [chef_gem](https://docs.chef.io/resource_chef_gem.html) resource.

You can also provide keys named `version`, `source` and `options` to
pass those to the underlying chef_gem resource, which allows you to
do things like use an internal Geminabox server:

    attributes:
      chef_vault_testfixtures:
        install_gems:
          db:
            options: --clear-sources --no-rdoc --no-ri --source https://gems.mycompany.int

### git installation method

For the installation type `git`, the value is a Hash with two keys:
`repository` and `revision`, which tell the cookbook where to clone the gem from
and what reference to check out before building and installing the gem.
This can be used to use a forked copy of a plugin gem:

    attributes:
      chef_vault_testfixtures:
        install_gems:
          db:
            install_type: git
            repository: https://github.com/otheruser/my_chef_vault_rmq_plugin.git
            revision: fix_for_something_or_other

## Whitelisting and Disregarding Plugins

If desired, you can whitelist and disregard plugins in the same
fashion as described in the gem documentation by overriding the
`plugins` and `disregard_plugins` attributes:

    suites:
      - name: default
        run_list:
          - recipe[chef_vault_testfixtures]
          - recipe[your_normal_cookbook_here]
        attributes:
          chef_vault_testfixtures:
            plugins: [ db ]
            disregard_plugin: [ rmq ]

Though in practice this is unnecessary because the only plugins that
will be available inside of the Test Kitchen box will be the ones you
reference using `install_gems`.

You may find these useful If you use a Vagrant image or AMI that has your
secret plugin gems 'baked' into the embedded chef-client ruby.

## Uploading your cookbook using berks upload

If you use `berks upload` to upload your cookbook to your Chef server, you
should add a switch to exclude the test cookbooks:

    berks upload --except test

If you don't do this, this cookbook will be uploaded, which shouldn't be a
problem (because it's not in the run list of any nodes), but it adds clutter
to your server.

## Resources

If you prefer, you can use the resources directly rather than using
the default recipe.

Because this requires a recipe context that comes before the cookbook
you're testing, this requires that you write a 'fixture cookbook'
that appears in the run list in `.kitchen.yml` before the cookbook
under test.

## chef_vault_testfixture_plugin

Installs a plugin gem that provides data for the chef-vault-testfixtures gem
to use.

### Example

    # default install type is 'chef_gem'
    c = chef_vault_testfixture_plugin 'my_vault_fixture_plugin' do
      action :nothing
      version '1.2.3'
      options '--no-rdoc --no-ri --clear-sources --source https://gems.mycompany.int'
    end
    c.run_action(:install)

    # using the 'git' install type
    chef_vault_testfixture_plugin 'my_vault_fixture_plugin' do
      action :nothing
      install_type 'git'
      repository 'https://git.mycompany.int/scm/gems/my_vault_testfixtures.git'
      revision 'v1.2.3'
    end
    c.run_action(:install)

### Parameters

* **gem_name**: the gem to install.  Defaults to the name of the resource.
* **action**: the only (and thus default) action for this resource is `:install`
* **install_type**: 'chef_gem' (which uses the like-named chef resource) or 'git'.  Defaults to 'git'
* **version**: the version of the gem to install.  If not set, the gem command will choose the newest version available.  Only used for 'chef_gem' install type.
* **options**: options to pass to the gem command.  Only used for the 'chef_gem' install type.
* **source**: the local path of a gem to install.  Only used for the 'chef_gem' install type.
* **repository**: the git URL to clone the gem from.  Only used for the 'git' install type.
* **revision**: the git reference to checkout before building the gem from source.  Only used for the 'git' install type.

## chef_vault_testfixtures

Creates a vault item for all chef-vault-testfixtures plugins that
can be found chef-vault-testfixtures gem.  It does this by dynamically
creating chef_vault_testfixture_vault resources (see below)

### Example

    c = chef_vault_testfixtures 'all' do
      action :nothing
      plugins %w(foo)
      disregard_plugins %w(bar)
    end
    c.run_action(:create)

### Parameters

* **name**: you can provide any name (this is required by chef)
* **action**: the only (and thus default) action for this resource is `:create`
* **plugins**: an array of plugins to load.  By default, this is empty, which means 'load all plugins matching `ChefVault::TestFixtures::`.  If set, only the named plugins will be used.
* **disregard_plugins**: an array of plugins to not load.  This prevents certain plugins from being loaded when the `plugins` attribute is empty.

## chef_vault_testfixture_vault

Creates a single vault item using fixture data from the named plugin.

This is generally not used directly; it is the workhorse for the
chef_vault_testfixtures resource.

### Example

    c = chef_vault_testfixture_vault 'db'
      action :nothing
    end
    c.run_action(:create)

### Parameters

* **plugin**: the test fixture plugin name.  Defaults to the name of the resource.
* **action**: the only  action for this resource is `:create`

## Compile-Time Resources

When you set up a vault for production use, you typically do so by hand
as an administrator before the recipe is converged on the server.  Because
the vault exists, you can make calls to `ChefVault::Item.load` at compile
time rather than converge time.

Because of this expectation on the part of cookbook authors, this cookbook
has to run its resources at compile time as well - otherwise the cookbook under
test might try to call `ChefVault::Item.load` before we had created
the vault item.

If you use the resources directly instead of via the default recipe,
you should ensure that they run at compile time as shown in the examples,
unless you are certain that your cookbook under test never attempts to
call `ChefVault::Item.load` from a recipe.  Calling it from provider or
library code should be fine.

## Errors when Converging Twice

When Test Kitchen first converges a node, it runs chef-client with a
validator key.  This causes chef-client to create a new client identity
and create a client.pem file as well as node and client objects in
/tmp/kitchen.

On a second converge, the node and client should again be available, but
Test Kitchen blows away the clients directory in /tmp/kitchen.  Because
the client.pem file is retained, chef-client does not re-create the client
object containing the public key for the node.

When chef-vault attempts to load the public key for the node, it fails,
preventing this cookbook from re-creating the testing vault.  This manifests
as this error on the second converge:

    ChefVault::Exceptions::ClientNotFound
    -------------------------------------
    default-ubuntu-1404 is not a valid chef client and/or node

This problem is explained in detail
[here](https://github.com/test-kitchen/test-kitchen/issues/602).  Until
the underlying issue is resolved, you must run the following command before
performing a second converge:

    kitchen exec -c 'sudo rm -rf /tmp/kitchen'

This removes the entire Test Kitchen chef repo directory, forcing the process
to start over and create a new node, client, and keypair.

## Supported Platforms

This cookbook is tested under Test Kitchen for the following platforms:

* ubuntu-12.04
* ubuntu-14.04
* centos-6.6
* centos-7.0

## Author

James FitzGibbon - james.i.fitzgibbon@nordstrom.com - @jf647

## License

Copyright (c) 2015 Nordstrom, Inc., All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
