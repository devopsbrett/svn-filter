class Repo < ActiveRecord::Base
	validates :url, presence: true
	validate :has_valid_protocol
	validates :name, presence: true, uniqueness: true, format: { with: /^[a-zA-Z0-9]*$/ }
  	attr_accessible :name, :protocol, :url

  	def self.valid_protocols
  		%w(svn http https svn+ssh)
  	end

  	def has_valid_protocol
  		unless self.class.valid_protocols.include?(protocol)
  			errors.add(:protocol, "must be one of #{self.class.valid_protocols.join(', ')}")
  		end
  	end
end
