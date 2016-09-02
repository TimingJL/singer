class Song < ApplicationRecord
	has_many :links
	accepts_nested_attributes_for :links, allow_destroy: true
	validates :title, presence: true
end
