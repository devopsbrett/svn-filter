class SvnsyncWorker
  include Sidekiq::Worker
  
  def perform(local_id)
    localrepo = LocalRepo.find(local_id)
    localrepo.local_repo_sync
  end

end
