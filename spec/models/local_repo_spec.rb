require 'spec_helper'

describe "An instance of", LocalRepo do

  it 'should be properly initialized' do
    expect(build(:local_repo)).to be_a(LocalRepo)
  end

  it 'only allows integer statuses' do
    expect(build(:local_repo_with_parent, status: 1)).to be_valid
    expect(build(:local_repo, status: "b")).to have(1).errors_on(:status)
    expect(build(:local_repo, status: 1.5)).to have(1).errors_on(:status)
  end

  it 'must have a unique path' do
    local_repo = create(:local_repo_with_parent)
    expect(build(:local_repo, path: local_repo.path)).to have(1).errors_on(:path)
  end

  it 'must have a path with a parent dir that exists' do
    missing_parent = File.expand_path('../../data/missing_dir/myrepo', __FILE__)
    expect(build(:local_repo, path: missing_parent)).to have(1).errors_on(:path)
  end

  it "must have a path with a parent dir that's writable" do
    unwritable_parent = File.expand_path('../../data/not_writable/myrepo', __FILE__)
    expect(build(:local_repo, path: unwritable_parent)).to have(1).errors_on(:path)
  end

  context 'when creating' do
    it "should have a path that doesn't exist" do
      existing_path = File.expand_path('../../data/existing_dir', __FILE__)
      expect(build(:local_repo, path: existing_path)).to have(1).errors_on(:path)
    end
  end

  context 'when empty' do
  	let(:empty_local_repo) { LocalRepo.new }

  	it { expect(empty_local_repo).to_not be_valid }
  	it { expect(empty_local_repo).to have_at_least(1).errors_on(:path) }
    it { expect(empty_local_repo).to have_at_least(1).errors_on(:repo) }
  	
    it 'has the status set to default (0)' do 
      expect(empty_local_repo.status).to eq(0)
    end
  end
end
