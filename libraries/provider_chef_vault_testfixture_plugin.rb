require 'chef/provider/lwrp_base'

require 'rubygems/specification'

# because most people try to load vault items in the
# compile phase, we have to install the plugin gems at
# compile time.
class Chef
  class Provider
    # provides the chef_vault_testfixtures_plugin resource
    class ChefVaultTestfixturePlugin < Chef::Provider::LWRPBase
      include ChefVaultTestFixtures::AtCompileTime

      use_inline_resources if defined?(use_inline_resources)

      def whyrun_supported?
        true
      end

      # dispatches to install_chef_gem or install_git based on
      # the install_type attribute of the resource
      action :install do
        case new_resource.install_type
        when 'chef_gem'
          install_chef_gem(new_resource)
        when 'git'
          install_git(new_resource)
        end
      end

      private

      # installs a chef-vault testfixture plugin gem using the
      # chef_gem resource
      # @param nr [Chef::Resource::ChefVaultTestfixturePlugin] the plugin resource
      # @return [void]
      def install_chef_gem(nr)
        # let chef_gem install the gem for us
        at_compile_time do
          chef_gem nr.gem_name do
            %w(options version source).each do |attr|
              value = new_resource.send(attr.to_sym)
              send(attr.to_sym, value) unless value.nil?
            end
          end
        end
      end

      # installs a chef-vault testfixture plugin gem using a
      # a git / ruby_block resource.  Technique borrowed from
      # https://github.com/optiflows-cookbooks/gem_specific_install
      # (which doesn't support compile time installation, which
      # we need)
      # @param nr [Chef::Resource] the chef node object
      # @return [void]
      def install_git(nr)
        install_git_packages
        checkout_path = clone_git_repo(nr)
        install_gem(nr, checkout_path)
      end

      # installs the git packages using the git cookbook
      # at compile time
      # @param node [Chef::Node] the node being converged
      # @return [void]
      def install_git_packages
        at_compile_time do
          package 'git'
        end
      end

      # clones a git repo containing a vault plugin gem
      # @param nr [Chef::Resource] the resource
      # @return [String] the path the git repo was cloned to
      def clone_git_repo(nr)
        checkout_path = ::File.join(Chef::Config[:file_cache_path], nr.gem_name)
        at_compile_time do
          git checkout_path do
            action :checkout
            repository nr.repository
            revision nr.revision
          end
        end
        checkout_path
      end

      # uses Rubygems to install the vault plugin gem
      # @param nr [Chef::Resource] the resource
      # @param checkout_path [String] the path the git repo was cloned to
      # @return [void]
      # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      def install_gem(nr, checkout_path)
        gemspec_file = ::File.join(
          checkout_path, "#{nr.gem_name}.gemspec"
        )
        at_compile_time do
          ruby_block "install vault plugin #{nr.gem_name}" do
            block do
              require 'rubygems/dependency_installer'
              require 'rubygems/specification'

              ::Dir.chdir(checkout_path)
              gemspec = ::Gem::Specification.load(gemspec_file)
              gem = if Gem::Package.respond_to?(:build)
                      Gem::Package.build(gemspec)
                    else
                      require 'rubygems/builder'
                      Gem::Builder.new(gemspec).build
                    end
              inst = ::Gem::DependencyInstaller.new
              inst.install gem
              Gem.clear_paths
            end
          end
        end
      end
      # rubocop:enable Metrics/AbcSize,Metrics/MethodLength
    end
  end
end
