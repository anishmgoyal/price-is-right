class QuestionController < ApplicationController

	require 'fileutils'

	before_filter :require_auth, only: [:read, :read_sum, :tick, :wait]
	before_filter :require_admin, only: [:list, :delete, :new, :create, :move_bottom]

	def wait

	end

	def list
		@questions = Question.all
	end

	def require_auth
		if session[:user_id]
			user = User.find_by id: session[:user_id]
			if user
				user.last_tick = Time.now.to_i
				user.save()
				@current_user = user
			else
				redirect_to controller: "user", action: "new"
			end
		else
			redirect_to controller: "user", action: "new"
		end
	end

	def require_admin
		if session[:user_id]
			user = User.find_by id: session[:user_id]
			if user && user.nickname == "admin"
				user.last_tick = Time.now.to_i
				user.save()
				@current_user = user
			else
				redirect_to action: "read", id: 1
			end
		else
			redirect_to action: "read", id: 1
		end
	end

	def new

	end

	def create
		question = Question.new
		question.question = params[:question]
		question.answer = params[:answer]
		question.save()
		file = params[:file]
		if file
			location = File.join("assets", question.id.to_s)
			question.image_location = location
			question.content_type = file.content_type
			question.save()
			FileUtils.mkdir_p(Rails.root.join("assets"))
			File.open(Rails.root.join(location), "wb") { |out| out.write(file.read) }
		end
		redirect_to action: "list"
	end

	def read
		question = Question.find_by id: params[:id]
		unless question
			question = Question.where(id: params[:id].to_i+1..Float::INFINITY).all.first
			if question
				id = question.id
				question = nil
				redirect_to action: "read", id: id
			else
				question = Question.where(id: -Float::INFINITY..params[:id].to_i).all.last
				if question
					id = question.id
					question = nil
					redirect_to action: "read", id: id
				else
					if @current_user.nickname == "admin"
						redirect_to action: "list"
					else
						redirect_to action: "wait"
					end
				end
			end
			return
		end
		if question
			@id = question.id
			@question = question.question
			@summary = true if params[:summary]
			@answer = params[:answer] if params[:answer]
			@error = params[:error] if params[:error]

			if @current_user.nickname == "admin"
			
				@prev_question = @id
				prev_question = Question.where(id: -Float::INFINITY..(@id - 1)).all.last
				if prev_question
					@prev_question = prev_question.id
				end
				
				@next_question = @id
				next_question = Question.where(id: (@id + 1)..Float::INFINITY).all.first
				if next_question
					@next_question = next_question.id
				end
			
				QuestionHelper.set_question(question.id)
			end
		else
			if @current_user.nickname == "admin"
				redirect_to action: "list"
			else
				redirect_to action: "wait"
			end
		end
	end

	def move_bottom
		question = Question.find_by id: params[:id]
		if question
			clone = Question.new
			clone.question = question.question
			clone.answer = question.answer
			clone.image_location = question.image_location
			clone.content_type = question.content_type
			clone.save
			question.responses.each do |r|
				r.question_id = clone.id
				r.save
			end
			question.destroy
		end
		redirect_to action: "list"
	end

	def answer
		question = Question.find_by id: params[:id]
		responses = Response.where(question_id: question.id).all
		if responses.length > 0
			#responses.each do |response|
			#	puts response.response
			#	response.response = (question.answer.to_i - response.response.to_i).abs
			#end
			response_list = []
			responses.each do |response|
				response_list << {diff: (question.answer.to_i-response.response.to_i).abs, id: response.id, date: response.created_at}
			end
			response_list.sort! do |a, b|
				comp = (a[:diff]) - (b[:diff])
				comp.zero? ? (b[:date]) <=> (a[:date]) : comp
			end
			#responses.sort do |a, b|
			#	comp = (a.response) <=> (b.response)
			#	comp.zero? ? (b.created_at) <=> (a.created_at) : comp
			#end
			correct = Response.find_by id: response_list.first[:id]
			user = correct.user
		end
		render json: {question: question, response: correct, user: user, responses_list: response_list, responses: responses}
	end

	def tick
		payload = {
			question: QuestionHelper.current_question
		}
		if @current_user.nickname == "admin"
			payload[:count] = Response.where(question_id: payload[:question]).count
		end
		render json: payload
	end

	def image
		question = Question.find_by id: params[:id]
		if question
			render status: 200, text: File.open(Rails.root.join(question.image_location), 'rb').read, content_type: question.content_type
		else
			render status: 404
		end
	end

	def delete
		question = Question.find_by id: params[:id]
		question.responses.each { |response| response.destroy } if question
		question.destroy if question
		redirect_to action: "list"
	end

end
