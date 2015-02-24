require 'spec_helper'

%w(test prod).each do |itemname|
  RSpec.describe "contents of vault bar/#{itemname}" do
    it 'should set bar to 1' do
      data = JSON.parse(IO.read("/tmp/kitchen/bar_#{itemname}.secret"))
      expect(data['raw_data']['bar']).to eq(1)
    end
  end
end
