require 'spec_helper'

RSpec.describe 'contents of vault foo/test' do
  it 'should set foo to 1' do
    data = JSON.parse(IO.read('/tmp/kitchen/foo_test.secret'))
    expect(data['raw_data']['foo']).to eq(1)
  end
end
