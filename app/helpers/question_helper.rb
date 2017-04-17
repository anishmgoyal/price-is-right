module QuestionHelper

	@@q = -1

	def self.current_question
		@@q
	end

	def self.set_question(q)
		@@q = q
	end

end