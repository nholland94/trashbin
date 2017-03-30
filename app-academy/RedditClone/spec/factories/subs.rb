# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sub do
    name { Faker::Internet.user_name }
    moderator_id { FactoryGirl.create(:user).id }
  end
end
