class AccountType < ActiveRecord::Base
  # Validation
  validates_presence_of :name, :title

  # Helpers
  def to_s
    title
  end
end
