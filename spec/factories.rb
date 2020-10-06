FactoryBot.define do
  factory :user_department do
    sequence(:name) { |n| "Department #{n}" }
  end

  factory :resb_trade_point do
    sequence(:name) { |n| "Trade Point #{n}" }
    sequence(:foreign_id, 1000)
  end

  factory :user do
    sequence(:login) { |n| "login_#{n}" }
  end
end