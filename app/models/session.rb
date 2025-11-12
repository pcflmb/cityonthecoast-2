# typed: true

class Session < ApplicationRecord
  belongs_to :user
end
