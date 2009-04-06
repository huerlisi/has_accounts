module Accounting
  class Account < ActiveRecord::Base
    belongs_to :holder, :polymorphic => true
  end
end
