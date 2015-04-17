# Revision History for chef_vault_testfixtures cookbook

## 0.2.0

* deprecate in favor of the chef-vault cookbook.  The gem that powered this cookbook now uses the same JSON file as the chef_vault_item helper so you only have to maintain one source of test data for your vaults

## 0.1.1

* ensure that the chef-vault-testfixtures gem is installed in the provider code before it is required
* use --conservative when installing chef-vault-testfixtures gem so as not to kick off an upgrade of chef
* expand test kitchen platforms to include chef-clients back to 11.10.x

## 0.1.0

* initial version
