class Repo < ActiveRecord::Base
  has_one :local, class_name: "LocalRepo", inverse_of: :repo
  validates :url, presence: true
  validate :has_valid_protocol
  validates :name, presence: true, uniqueness: true, format: { with: /^[a-zA-Z0-9_-]*$/ }
  validates_associated :local
  attr_accessible :name, :protocol, :url, :local_attributes
  accepts_nested_attributes_for :local, allow_destroy: true

  VALID_PROTOCOLS = %w(svn http https svn+ssh)

  def has_local?
    !local.nil?
  end
  
  def has_valid_protocol
    unless VALID_PROTOCOLS.include?(protocol)
      errors.add(:protocol, "must be one of #{VALID_PROTOCOLS.join(', ')}")
    end
  end
end
