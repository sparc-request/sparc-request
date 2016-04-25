require 'rails_helper'

RSpec.describe Portal::ProtocolsController do

  stub_portal_controller

  let!(:identity) { create(:identity)}

  before(:each) { session[:identity_id] = identity.id }

  describe 'GET #index.js' do

  	let!(:archived_protocol)   { create(:protocol_without_validations, archived: true) }
  	let!(:unarchived_protocol) { create(:protocol_without_validations) }

    before do
    	create(:project_role_approve, protocol: unarchived_protocol,
                                    identity: identity)
    	create(:project_role_approve, protocol: archived_protocol,
                                    identity: identity)
    end

  	context 'default portal view' do

  	  before { xhr :get, :index, format: :js }

  	  it 'does not contain archived protocol' do
  	    expect(assigns(:protocols)).to eq([unarchived_protocol])
  	  end
  	end

  	context 'filtered portal view' do

  	  before { xhr :get, :index, include_archived: 'true', format: :js }

  	  it 'shows archived and unarchived protocols' do
  		  expect(assigns(:protocols).sort).to eq([archived_protocol, unarchived_protocol])
  	  end
  	end
  end

  describe 'PUT #update_protocol_type' do

    context 'virgin project with sub_service_request' do
      
      build_study_type_question_groups
      let!(:project) { create(:protocol_without_validations, type: 'Project', selected_for_epic: nil, study_type_question_group_id: inactive_study_type_question_group.id)}
      let!(:service_request) { create(:service_request_without_validations, protocol_id: project.id)}
      let!(:sub_service_request) { create(:sub_service_request, service_request_id: service_request.id, organization: create(:organization))}
      before :each do
        create(:project_role_approve, protocol: project, identity: identity)   
        xhr :put, :update_protocol_type, protocol:{type: 'Study'}, id: project.id, sub_service_request_id: sub_service_request.id ,format: :js
      end

      it 'should activate the virgin project' do
        expect(project.reload.active?).to eq(true)
      end

      it 'should update virgin project to type study' do
        expect(project.reload.type).to eq('Study')
      end

      it 'should redirect to admin/portal' do
        expect(response).to redirect_to portal_admin_sub_service_request_path(sub_service_request)
      end
    end 
    context 'study with sub_service_request' do
      
      build_study_type_question_groups
      let!(:study) { create(:protocol_without_validations, type: 'Study', selected_for_epic: true, study_type_question_group_id: active_study_type_question_group.id)}
      let!(:service_request) { create(:service_request_without_validations, protocol_id: study.id)}
      let!(:sub_service_request) { create(:sub_service_request, service_request_id: service_request.id, organization: create(:organization))}
      before :each do
        create(:project_role_approve, protocol: study, identity: identity)   
        xhr :put, :update_protocol_type, protocol:{type: 'Project'}, id: study.id, sub_service_request_id: sub_service_request.id ,format: :js
      end

      it 'should update study to type project' do
        expect(study.reload.type).to eq('Project')
      end

      it 'should redirect to admin/portal' do
        expect(response).to redirect_to portal_admin_sub_service_request_path(sub_service_request)
      end
    end 

    context 'study without sub_service_request' do
      
      build_study_type_question_groups
      let!(:study) { create(:protocol_without_validations, type: 'Study', selected_for_epic: true, study_type_question_group_id: active_study_type_question_group.id)}
      before :each do
        create(:project_role_approve, protocol: study, identity: identity)   
        xhr :put, :update_protocol_type, protocol:{type: 'Project'}, id: study.id, format: :js
      end

      it 'should update study to type project' do
        expect(study.reload.type).to eq('Project')
      end

      it 'should activate the study' do
        expect(study.reload.active?).to eq(true)
      end

      it 'should redirect to admin/portal' do
        expect(response).to redirect_to edit_portal_protocol_path(study)
      end
    end 

    context 'project without sub_service_request' do
      
      build_study_type_question_groups
      let!(:project) { create(:protocol_without_validations, type: 'Project', selected_for_epic: true, study_type_question_group_id: active_study_type_question_group.id)}
      before :each do
        create(:project_role_approve, protocol: project, identity: identity)   
        xhr :put, :update_protocol_type, protocol:{type: 'Study'}, id: project.id, format: :js
      end

      it 'should update project to type project' do
        expect(project.reload.type).to eq('Study')
      end

      it 'should activate the project' do
        expect(project.reload.active?).to eq(true)
      end

      it 'should redirect to admin/portal' do
        expect(response).to redirect_to edit_portal_protocol_path(project)
      end
    end 

  end
end
