require 'spec_helper'

describe file('/tmp/kitchen/foo_test.secret') do
  it { should be_file }
end

describe file('/tmp/kitchen/bar_test.secret') do
  it { should be_file }
end

describe file('/tmp/kitchen/bar_prod.secret') do
  it { should be_file }
end
