# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :repo do
    sequence(:name) { |n| "MyRepo#{n}" }
    protocol "svn"
    url "svntest.foxienet.com/traceper"
  end
end
