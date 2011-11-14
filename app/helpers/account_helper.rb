module AccountHelper
  def accounts_as_collection(accounts = nil)
    accounts ||= Account.all
    accounts.collect{|account| ["%s - %s" % [account.code, account.title], account.id]}
  end
end
