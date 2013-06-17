require 'spec_helper'

describe "An external", Repo do
		
	it 'should be properly initialized' do
		expect(create(:repo)).to be_a(Repo)
	end

	it "must have unique name" do
		myrepo = create(:repo)
		expect(build(:repo, name: myrepo.name)).to have(1).errors_on(:name)
	end

	it "only allows an alphanumeric name" do
		expect(build(:repo, name: "Invalid Name")).to have(1).errors_on(:name)
	end

	context 'when empty' do
		let(:empty_repo) { Repo.build }

		it { expect(:empty_repo).to have_at_least(1).errors_on(:name) }
		it { expect(:empty_repo).to have_at_least(1).errors_on(:protocol) }
		it { expect(:empty_repo).to have_at_least(1).errors_on(:url) }
	end

	context 'with valid data' do
		let(:repo) { create(:repo) }
		it { expect(repo).to be_valid }

		it "must allow any of the valid protocols" do
			["svn", "http", "https", "svn+ssh"].each do |p|
				expect(build(:repo, protocol: p)).to be_valid
			end
		end
	end

end
