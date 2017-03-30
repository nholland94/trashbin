# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :link do
    title { Faker::Lorem.sentence }
    url { Faker::Internet.domain_name }
    text { rand(2) == 0 ? Faker::Lorem.paragraph : nil }
    user_id { FactoryGirl.create(:user).id }
  end
end
