require 'spec_helper'

describe Account do
  subject { FactoryGirl.build :account }
  
  it { should accept_values_for(:title, "Test", "Test Account!") }
  it { should_not accept_values_for(:title, "", nil) }
end
