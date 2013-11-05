require 'spec_helper'

describe Account do
  subject { FactoryGirl.build :account }

  it { should accept_values_for(:title, "Test", "Test Account!") }
  it { should_not accept_values_for(:title, "", nil) }

  it { should accept_values_for(:code, "test", "test_account") }
  it { should_not accept_values_for(:code, "", nil) }

  it { should accept_values_for(:account_type, FactoryGirl.build(:current_assets), FactoryGirl.build(:costs) ) }
  it { should_not accept_values_for(:account_type, nil) }

  describe '.parent' do
    let(:parent) { FactoryGirl.build :account, :code => '3000' }

    it 'Should accept a parent account' do
      child = FactoryGirl.build :account, :code => '3100', :parent => parent

      child.parent.should == parent
    end
  end
end
