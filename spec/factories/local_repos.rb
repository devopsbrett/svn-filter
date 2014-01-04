# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :local_repo do
    sequence(:path) { |n| "#{LocalRepo::DEFAULT_BASE_PATH}/MyPath#{n}" }
    status 0

    factory :local_repo_with_parent do
      repo
      path { "#{LocalRepo::DEFAULT_BASE_PATH}/#{repo.name}" }
    end
  end
end

#File.expand_path('../../../data', '/home/ezfoxie/projects/ruby/svn-filter/spec/factories/local_repos.rb')
