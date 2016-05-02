require 'rails_helper'

RSpec.describe Dashboard::ProtocolsController do
  describe 'put update' do
    let!(:identity_stub) { instance_double('Identity', id: 1) }

    before(:each) do
      log_in_dashboard_identity(obj: identity_stub)
    end

    describe 'authorization' do
      render_views

      context 'user not authorized to edit Protocol' do
        it 'should render error message' do
          protocol = findable_stub(Protocol) do
            instance_double(Protocol,
              id: 1,
              type: :protocol_type)
          end
          authorize(identity_stub, protocol, can_edit: false)

          xhr :get, :update, id: 1

          expect(response).to render_template('service_requests/_authorization_error')
        end
      end
    end

    context 'params[:protocol] results in valid Protocol' do
      it 'should set flash[:success], set Protocol\'s StudyTypeQuestionGroup to an active one, and not set @errors' do
        # stub an active StudyTypeQuestionGroup
        allow(StudyTypeQuestionGroup).to receive(:active_id).and_return(2)

        protocol_stub = findable_stub(Protocol) do
          instance_double(Protocol, id: 1, type: 'Project')
        end
        protocol_attributes = { some_attribute: 'some value' }
        expect(protocol_stub).to receive(:update_attributes).
          with(protocol_attributes.
            merge(study_type_question_group_id: 2).
            stringify_keys).
          and_return(true)

        authorize(identity_stub, protocol_stub, can_edit: true)

        xhr :get, :update, id: 1, protocol: protocol_attributes

        expect(flash[:success]).to eq('Project Updated!')
        expect(assigns(:errors)).to be_nil
      end
    end

    context 'params[:protocol] results in invalid Protocol' do
      it 'should set @errors to Protocol\'s errors attribute' do
        # stub an active StudyTypeQuestionGroup
        allow(StudyTypeQuestionGroup).to receive(:active_id).and_return(2)

        protocol_stub = findable_stub(Protocol) do
          instance_double(Protocol,
            id: 1,
            type: 'Project',
            errors: 'oh god')
        end
        protocol_attributes = { some_attribute: 'some value' }
        expect(protocol_stub).to receive(:update_attributes).
          and_return(false)

        authorize(identity_stub, protocol_stub, can_edit: true)

        xhr :get, :update, id: 1, protocol: protocol_attributes

        expect(assigns(:errors)).to eq('oh god')
      end
    end
  end

  def authorize(identity, protocol, opts = {})
    auth_mock = instance_double('ProtocolAuthorizer',
      'can_view?' => opts[:can_view].nil? ? false : opts[:can_view],
      'can_edit?' => opts[:can_edit].nil? ? false : opts[:can_edit])
    expect(ProtocolAuthorizer).to receive(:new).
      with(protocol, identity).
      and_return(auth_mock)
  end
end
