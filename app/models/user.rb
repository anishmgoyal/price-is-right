class User < ActiveRecord::Base

	has_many :responses

	validates :nickname, presence: true

end
