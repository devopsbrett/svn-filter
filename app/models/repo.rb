class Repo < ActiveRecord::Base
  attr_accessible :name, :protocol, :url
end
