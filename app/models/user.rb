# frozen_string_literal: true

class User < ApplicationRecord
  has_many :barbecues, inverse_of: :owner, foreign_key: 'owner_id'
end
