class User < ApplicationRecord
    has_many :appointments

    validates :name, format: { with: /\A[[:alpha:]]{2,} [[:alpha:]\s]{2,}/i, on: :create }
    validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create }
end
