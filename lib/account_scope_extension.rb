module AccountScopeExtension
  def saldo(selector = Date.today, inclusive = true)
    new_saldo = 0

    for account in all
      new_saldo += account.saldo(selector, inclusive)
    end

    return new_saldo
  end
end
