class LocalRepo < ActiveRecord::Base
  belongs_to :repo, inverse_of: :local
  validates :repo, presence: true
  validates :path, presence: true, uniqueness: true
  validates :status, presence: true, numericality: { only_integer: true }
  validate :parent_dir_exists, :parent_dir_is_writable
  validate :path_doesnt_exist, on: :create
  attr_accessible :path
  after_initialize :init
  before_update :check_path_change
  after_save :mirror_repo

  DEFAULT_BASE_PATH = File.expand_path('../../../data', __FILE__)
  STATUS_PENDING = 0
  STATUS_REPO_CREATED = 1
  STATUS_REPO_HOOKS_ADDED = 2
  STATUS_REPO_SYNC_INIT = 3
  STATUS_REPO_SYNCED = 4

  def local_repo_sync(one_step = false)
    stoploop = false
    until stoploop
      case status
      when STATUS_PENDING
        create_repo
      when STATUS_REPO_CREATED
        add_hooks
      when STATUS_REPO_HOOKS_ADDED
        svnsync_init
      when STATUS_REPO_SYNC_INIT, STATUS_REPO_SYNCED
        svnsync_sync        
      end
      stoploop = one_step || status < 0 || status == STATUS_REPO_SYNCED
    end
  end

  def parent_dir_exists
  	unless File.directory?(parent_dir(path))
      errors.add(:path, "must be in an existing directory")
    end
  end

  def parent_dir_is_writable
    path_parent = parent_dir(path)
    if File.directory?(path_parent) and !File.writable?(path_parent)
      errors.add(:path, "is not writable")
    end
  end

  def path_doesnt_exist
    if !path.nil? and File.writable?(parent_dir(path)) and File.exist?(path)
      errors.add(:path, "already exists")
    end
  end

private

  def create_repo
    if svnadmin_create(path)
      update_attribute(:status, STATUS_REPO_CREATED)
    else
      update_attribute(:status, -1)
    end
  end

  def add_hooks
    revprop_hook = File.join(path, 'hooks', 'pre-revprop-change')
    f = File.new(revprop_hook, File::CREAT|File::TRUNC|File::RDWR, 0755)
    f.write(<<-EOF
#!/bin/sh
USER="$3"
if [ "$USER" = "svnsync" ]; then exit 0; fi
echo "Only the svnsync user can change revprops" >&2
exit 1
    EOF
    )
    f.close
    update_attribute(:status, STATUS_REPO_HOOKS_ADDED)
  end

  def svnsync_init
    if svnsync('init', path, {remote: repo.full_url})
      update_attribute(:status, STATUS_REPO_SYNC_INIT)
    else
      update_attribute(:status, -1)
    end
  end

  def svnsync_sync
    if svnsync('synchronize', path)
      update_attribute(:status, STATUS_REPO_SYNCED)
    else
      update_attribute(:status, -1)
    end
  end

  def svnadmin_create(path_name)
    system("svnadmin create #{path_name}")
  end

  def svnsync(action, path_name, options = {})
    if action == "init"
      cmd = "svnsync init --username svnsync --non-interactive file://#{path_name} #{options[:remote]}"
    elsif action == "synchronize"
      cmd = "svnsync synchronize file://#{path_name}"
    end
    system(cmd)
  end
  
  def parent_dir(dir)
    File.expand_path('../', dir)
  end

  def init
    self.status ||= 0
  end

  def check_path_change
    if changed? and changes.include?("path")
      self.status = 0
    end
  end

  def mirror_repo
    if status == 0
      SvnsyncWorker.perform_async(id)
    end
  end

end
