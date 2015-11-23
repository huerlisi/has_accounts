require 'spec_helper'

describe Account do
  subject { FactoryGirl.build :account }

  it { is_expected.to accept_values_for(:title, 'Test', 'Test Account!') }
  it { is_expected.not_to accept_values_for(:title, '', nil) }

  it { is_expected.to accept_values_for(:code, 'test', 'test_account') }
  it { is_expected.not_to accept_values_for(:code, '', nil) }

  it { is_expected.to accept_values_for(:account_type, FactoryGirl.build(:current_assets), FactoryGirl.build(:costs)) }
  it { is_expected.not_to accept_values_for(:account_type, nil) }

  describe '#parent' do
    let(:parent) { FactoryGirl.build :account, code: '3000' }

    it 'should accept a parent account' do
      child = FactoryGirl.build :account, code: '3100', parent: parent

      expect(child.parent).to eq(parent)
    end
  end

  describe '#unbalanced_references' do
    let!(:account) { FactoryGirl.create :account }

    it 'should call unbalanced_by_grouped_reference on bookings with account' do
      allow(account).to receive_message_chain(:bookings, :unbalanced_by_grouped_reference).and_return('result')
      expect(account.unbalanced_references).to eq('result')
    end
  end

  context 'with tagging support' do
    describe '.find_by_tag' do
      let!(:account) { FactoryGirl.create(:account, tag_list: tag) }
      let(:tag) { 'asd:123' }

      context 'one account found with this tag' do
        specify { expect(Account.find_by_tag(tag)).to eq(account) }
      end

      context 'multiple accounts found with this tag' do
        before do
          FactoryGirl.create(:account, tag_list: tag)
        end

        it 'raises Account::AmbiguousTag' do
          expect { Account.find_by_tag(tag) }.to raise_error(Account::AmbiguousTag)
        end
      end
    end
  end
end
