class ResponseController < ApplicationController

	before_filter :require_auth

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

	def create
		qid = params[:question_id]
		uid = @current_user.id

		response_curr = Response.where(question_id: qid, user_id: uid).all.first
		if response_curr
			redirect_to controller: "question", action: "read", id: qid, summary: true, answer: response_curr.response
			return
		end

		r = Response.new
		r.question_id = qid
		r.user_id = uid
		resp = params[:response].to_s.tr('$', '').gsub(/,/, '').to_i
		if resp == 0 && params[:response] != "0" && params[:response] != "$0" && params[:response] != "0.00" && params[:response] != "$0.00"
			redirect_to controller: "question", action: "read", id: qid, error: "The value you entered is not a price"
			return
		end
		r.response = resp
		r.save()
		redirect_to controller: "question", action: "read", id: qid, summary: true, answer: resp
	end

end
