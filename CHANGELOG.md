# Revision History for chef_vault_testfixtures cookbook 

## 0.1.1

* ensure that the chef-vault-testfixtures gem is installed in the provider code before it is required
* use --conservative when installing chef-vault-testfixtures gem so as not to kick off an upgrade of chef
* expand test kitchen platforms to include chef-clients back to 11.10.x

## 0.1.0

* initial version
