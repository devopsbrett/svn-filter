class LocalRepo < ActiveRecord::Base
  belongs_to :repo
  validates :repo, presence: true
  validates :path, presence: true, uniqueness: true
  validates :status, presence: true, numericality: { only_integer: true }
  validate :parent_dir_exists, :parent_dir_is_writable
  validate :path_doesnt_exist, on: :create
  attr_accessible :path, :status
  after_initialize :init

  DEFAULT_BASE_PATH = File.expand_path('../../../data', __FILE__)

  def init
  	self.status ||= 0
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
  
  def parent_dir(dir)
    File.expand_path('../', dir)
  end

end
