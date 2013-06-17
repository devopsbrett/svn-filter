# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :local_repo do
    repo nil
    path "MyString"
    status 1
  end
end
