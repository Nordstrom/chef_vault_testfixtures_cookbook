#
# Copyright 2014, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Adapted from libraries/timing.rb in the build_essential cookbook
# to provde sugar to run resources at compile time
class CompileTime
  def initialize(recipe)
    @recipe = recipe
  end

  def evaluate(&block)
    instance_eval(&block)
  end

  def method_missing(m, *args, &block)
    resource = @recipe.send(m, *args, &block)
    if resource.is_a?(Chef::Resource)
      actions  = Array(resource.action)
      resource.action(:nothing)

      actions.each do |action|
        resource.run_action(action)
      end
    end
    resource
  end
end

module ChefVaultTestFixtures
  # borrowed from chef-sugar via the build_essentials cookbook
  module AtCompileTime
    # evaluate the given block at compile time
    # @param [Proc] block the thing to eval
    def at_compile_time(&block)
      CompileTime.new(self).evaluate(&block)
    end
  end
end

# Include the module into the main recipe DSL
Chef::Recipe.send(:include, ChefVaultTestFixtures::AtCompileTime)
