class AccountType < ActiveRecord::Base
  # Access restrictions
  attr_accessible :title, :name

  # Validation
  validates_presence_of :name, :title

  # Helpers
  def to_s
    title
  end
end
