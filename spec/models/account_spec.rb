describe Account do
  subject { FactoryGirl.build :account }
  
  its(:title) { should == 'Test Account' }
end
