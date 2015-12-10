require 'rails_helper'

RSpec.describe ServiceRequestsController do
  stub_controller

  let_there_be_lane
  let_there_be_j
  build_service_request

  describe 'POST ask_a_question' do

    context 'params[:quick_question][:email] and params[:quick_question][:body] absent' do

      it 'should call ask_a_question and then deliver from NO_REPLY_FROM with body "No question asked"' do
        deliverer = double()
        expect(deliverer).to receive(:deliver)
        allow(Notifier).to receive(:ask_a_question) do |quick_question|
          expect(quick_question.to).to eq DEFAULT_MAIL_TO
          expect(quick_question.from).to eq NO_REPLY_FROM
          expect(quick_question.body).to eq 'No question asked'
          deliverer
        end
        xhr :get, :ask_a_question, { quick_question: { email: ''}, quick_question: { body: ''}, id: service_request.id, format: :js }
      end
    end

    context 'params[:quick_question][:email] present' do

      it 'should use question email' do
        deliverer = double()
        expect(deliverer).to receive(:deliver)
        allow(Notifier).to receive(:ask_a_question) do |quick_question|
          expect(quick_question.from).to eq 'from-here@musc.edu'
          deliverer
        end
        xhr :get, :ask_a_question, { id: service_request.id, quick_question: { email: 'from-here@musc.edu' , body: '' }, format: :js }
      end
    end

    context 'params[:quick_question][:body] present' do

      it 'should use question body' do
        deliverer = double()
        expect(deliverer).to receive(:deliver)
        allow(Notifier).to receive(:ask_a_question) do |quick_question|
          expect(quick_question.body).to eq 'is this thing on?'
          deliverer
        end
        xhr :get, :ask_a_question, { id: service_request.id, quick_question: { email: '' }, quick_question: { body: 'is this thing on?' }, format: :js }
      end
    end
  end
end
