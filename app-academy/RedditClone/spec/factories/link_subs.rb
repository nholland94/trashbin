# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :link_sub do
    link_id { FactoryGirl.create(:link).id }
    sub_id { FactoryGirl.create(:sub).id }
  end
end
