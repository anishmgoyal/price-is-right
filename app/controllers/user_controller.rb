class UserController < ApplicationController

	include QuestionHelper

	def new
		if session[:user_id]
			redirect_to action: "logout"
			return
		end
		@error = params[:error]
	end

	def create
		user = User.find_by nickname: params[:nickname]
		if user && user.last_tick + 15 > Time.now.to_i || (params[:nickname] == "admin" && params[:password] != "price is right")
			redirect_to action: "new", error: "That nickname is currently in use."
		else
			if user
				user.responses.each do |response|
					response.destroy
				end
				user.destroy
				user = nil
			end
			if params[:nickname] == "admin"
				Response.all.each do |response|
					response.destroy
				end
			end
			user = User.new
			user.nickname = params[:nickname]
			user.last_tick = Time.now.to_i
			user.save()
			session[:user_id] = user.id
			if user.nickname == "admin"
				redirect_to controller: "question", action: "read", id: "1"
			else
				redirect_to controller: "question", action: "wait"
			end
		end
	end

	def logout
		if session[:user_id]
			user = User.find_by id: session[:user_id]
			if user
				user.responses.each do |response|
					response.destroy
				end
				user.destroy
				if user.nickname == "admin"
					QuestionHelper.set_question(-1)
				end
			end
		end
		session[:user_id] = nil
		redirect_to action: "new"
	end

end