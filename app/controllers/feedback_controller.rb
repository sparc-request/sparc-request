class FeedbackController < ApplicationController

  def new
    @feedback = Feedback.new
    respond_to do |format|
      format.js
    end
  end

  def create
    @feedback = Feedback.new(feedback_params)
    respond_to do |format|
      if @feedback.valid?
        emitter = RedcapSurveyEmitter.new(@feedback)
        emitter.send_form
        format.js
      else
        format.json { render json: @feedback.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def feedback_params
    params.require(:feedback).permit(:name, :email, :date,
                                     :typeofrequest, :priority,
                                     :browser, :version, :sparc_request_id
                                    )
  end
end
