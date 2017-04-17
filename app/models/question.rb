class Question < ActiveRecord::Base

	has_many :responses

	validates :question, blank: false

end