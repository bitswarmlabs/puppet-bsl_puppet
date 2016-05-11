require 'spec_helper'
describe 'bsl_puppet' do

  context 'with default values for all parameters' do
    it { should contain_class('bsl_puppet') }
  end
end
