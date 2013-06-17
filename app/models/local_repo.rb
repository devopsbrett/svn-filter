class LocalRepo < ActiveRecord::Base
  belongs_to :repo
  attr_accessible :path, :status
end
