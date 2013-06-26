# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :repo do
    sequence(:name) { |n| "MyRepo#{n}" }
    protocol "svn"
    url "svntest.foxienet.com/traceper"

    factory :repo_with_local do
    	after(:create) do |repo|
    		FactoryGirl.create(:local_repo, repo: repo)
    	end
    end
  end
end