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

  describe 'on #save' do
    context 'when creating' do
      it "should have a path that doesn't exist" do
        existing_path = File.expand_path('../../data/existing_dir', __FILE__)
        expect(build(:local_repo, path: existing_path)).to have(1).errors_on(:path)
      end

      it "should add a background job to create the local repo" do
        expect{ create(:local_repo_with_parent) }.to change(SvnsyncWorker.jobs, :size).by(1)
      end
    end

    context 'when updating' do
      let(:local_repo) { create(:local_repo_with_parent, status: 2) }

      it "should reset the status if the path is changed" do
        local_repo.path = File.expand_path("#{DATA_DIR}/new_path", __FILE__)
        local_repo.save
        expect(local_repo.status).to eq(0)
      end

      it "should create a background job to create a local repo if the path is changed" do
        local_repo.path = File.expand_path("#{DATA_DIR}/new_path", __FILE__)
        expect{ local_repo.save }.to change(SvnsyncWorker.jobs, :size).by(1)
      end
    end
  end

  describe '#local_repo_sync' do
    let(:local_repo) { create(:local_repo_with_parent, path: File.join(DATA_DIR, 'new_path')) }
    before(:each) {
      repodir = File.join(DATA_DIR, 'new_path')
      FileUtils.rm_rf(repodir) if File.exist?(repodir)
    }

    context "when path first set or changed" do
      it "should create an empty svn repo at PATH" do
        local_repo.local_repo_sync(true)
        expect(File.exist?(local_repo.path)).to be_true
      end

      it "should update status to 1 if repo created" do
        local_repo.local_repo_sync(true)
        expect(local_repo.status).to eq(LocalRepo::STATUS_REPO_CREATED)
      end

      it "should update status to -1 if there was an error" do
        LocalRepo.any_instance.stub(:svnadmin_create).and_return(false)
        local_repo.local_repo_sync(true)
        expect(local_repo.status).to eq(-1)
      end
    end

    context "after local repo created" do
      before(:each) { local_repo.local_repo_sync(true) }

      it "should create pre-revprop-change hook" do
        local_repo.local_repo_sync(true)
        expect(File.exist?(File.join(local_repo.path, 'hooks', 'pre-revprop-change'))).to be_true
      end

      it "should update status to 2" do
        local_repo.local_repo_sync(true)
        expect(local_repo.status).to eq(LocalRepo::STATUS_REPO_HOOKS_ADDED)
      end
    end

    context "after revprop-change hook created" do
      before(:each) {
        local_repo.local_repo_sync(true)
        local_repo.local_repo_sync(true)
      }

      it "should init svnsync and update status to 3" do
        LocalRepo.any_instance.stub(:svnsync).and_return(true)
        local_repo.local_repo_sync(true)
        expect(local_repo.status).to eq(LocalRepo::STATUS_REPO_SYNC_INIT)
      end

      it "should update status to -1 if there was an error" do
        LocalRepo.any_instance.stub(:svnsync).and_return(false)
        local_repo.local_repo_sync(true)
        expect(local_repo.status).to eq(-1)
      end
    end

    context "after svnsync initialized" do
      before(:each) {
        local_repo.status = LocalRepo::STATUS_REPO_SYNC_INIT
      }

      it "should sync svn and update status to 4" do
        LocalRepo.any_instance.stub(:svnsync).and_return(true)
        local_repo.local_repo_sync(true)
        expect(local_repo.status).to eq(LocalRepo::STATUS_REPO_SYNCED)
      end

      it "should update status to -1 if there was an error" do
        LocalRepo.any_instance.stub(:svnsync).and_return(false)
        local_repo.local_repo_sync(true)
        expect(local_repo.status).to eq(-1)
      end
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
