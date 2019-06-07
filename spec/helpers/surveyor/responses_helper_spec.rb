# Copyright © 2011-2019 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

require 'rails_helper'

RSpec.describe Surveyor::ResponsesHelper, type: :helper do
  stub_config('site_admins', ["abc123"])

  let!(:organization) { create(:organization) }

  before :each do
    @site_admin = create(:identity, ldap_uid: 'abc123')
    @user       = create(:identity)
  end

  describe 'response_options' do
    context 'view_response_button' do
      context 'for System Surveys' do
        context 'system satisfaction surveys' do
          let!(:survey)   { create(:system_survey, access_code: 'system-satisfaction-survey', active: true) }
          let!(:response) { create(:response, survey: survey, identity: build(:identity)) }

          before :each do
            allow(response).to receive(:completed?).and_return(true)
          end

          context 'user is a site admin' do
            before :each do
              ActionView::Base.send(:define_method, :current_user) { @site_admin }
            end

            it 'should return enabled button' do
              expect(helper.response_options(response, []).split("</a>").first.include?('disabled')).to eq(false)
            end
          end

          context 'user is not a site admin' do
            before :each do
              ActionView::Base.send(:define_method, :current_user) { @user }
            end

            it 'should return disabled button' do
              expect(helper.response_options(response, []).split("</a>").first.include?('disabled')).to eq(true)
            end
          end
        end

        context 'service surveys' do
          let!(:survey)     { create(:system_survey, active: true) }
          let!(:response)   { create(:response, survey: survey, identity: build(:identity)) }
          let!(:asso_surv)  { create(:associated_survey, associable: organization, survey: survey) }

          before :each do
            ActionView::Base.send(:define_method, :current_user) { @user }
            allow(response).to receive(:completed?).and_return(true)
          end

          context 'user is a super user' do
            let!(:su) { create(:super_user, organization: organization, identity: @user) }

            it 'should return enabled button' do
              expect(helper.response_options(response, [survey]).split("</a>").first.include?('disabled')).to eq(false)
            end
          end

          context 'user is not a super user' do
            it 'should return disabled button' do
              expect(helper.response_options(response, []).split("</a>").first.include?('disabled')).to eq(true)
            end
          end
        end

        context 'response is incomplete' do
          let!(:survey)   { create(:system_survey, active: true) }
          let!(:response) { create(:response, survey: survey, identity: build(:identity)) }

          before :each do
            allow(response).to receive(:completed?).and_return(false)
          end

          it 'should return disabled button' do
            expect(helper.response_options(response, []).split("</a>").first.include?('disabled')).to eq(true)
          end
        end
      end

      context 'for Forms' do
        let!(:form)     { create(:form, surveyable: organization, active: true) }
        let!(:response) { create(:response, survey: form, identity: build(:identity)) }

        before :each do
          ActionView::Base.send(:define_method, :current_user) { @user }
        end

        context 'user is a super user for surveyable' do
          let!(:su) { create(:super_user, organization: organization, identity: @user) }

          before :each do
            allow(response).to receive(:completed?).and_return(true)
          end

          it 'should return enabled button' do
            expect(helper.response_options(response, [form]).split("</a>").first.include?('disabled')).to eq(false)
          end
        end

        context 'user is a service provider for association' do
          let!(:sp) { create(:service_provider, organization: organization, identity: @user) }

          before :each do
            allow(response).to receive(:completed?).and_return(true)
          end

          it 'should return enabled button' do
            expect(helper.response_options(response, [form]).split("</a>").first.include?('disabled')).to eq(false)
          end
        end

        context 'user is not a super user or service provider for surveyable' do
          before :each do
            allow(response).to receive(:completed?).and_return(true)
          end

          it 'should return disabled button' do
            expect(helper.response_options(response, []).split("</a>").first.include?('disabled')).to eq(true)
          end
        end

        context 'response is incomplete' do
          before :each do
            allow(response).to receive(:completed?).and_return(false)
          end

          it 'should return disabled button' do
            expect(helper.response_options(response, []).split("</a>").first.include?('disabled')).to eq(true)
          end
        end
      end
    end

    context 'edit_response_button' do
      context 'for System Surveys' do
        let!(:survey)     { create(:system_survey, active: true) }
        let!(:response)   { create(:response, survey: survey, identity: build(:identity)) }

        context 'user is a site admin' do
          before :each do
            ActionView::Base.send(:define_method, :current_user) { @site_admin }
            allow(response).to receive(:completed?).and_return(true)
          end

          it 'should return enabled button' do
            expect(helper.response_options(response, []).split("</a>").last.include?('disabled')).to eq(false)
          end
        end

        context 'user is not a site admin' do
          before :each do
            ActionView::Base.send(:define_method, :current_user) { @user }
            allow(response).to receive(:completed?).and_return(true)
          end

          it 'should return disabled button' do
            expect(helper.response_options(response, []).split("</a>").last.include?('disabled')).to eq(true)
          end
        end

        context 'response is incomplete' do
          before :each do
            ActionView::Base.send(:define_method, :current_user) { @user }
            allow(response).to receive(:completed?).and_return(false)
          end

          it 'should return disabled button' do
            expect(helper.response_options(response, []).split("</a>").last.include?('disabled')).to eq(true)
          end
        end
      end

      context 'for Forms' do
        let!(:form)     { create(:form, surveyable: organization, active: true) }
        let!(:response) { create(:response, survey: form, identity: build(:identity)) }

        before :each do
          ActionView::Base.send(:define_method, :current_user) { @user }
        end

        context 'user is a super user for surveyable' do
          let!(:su) { create(:super_user, organization: organization, identity: @user) }

          before :each do
            allow(response).to receive(:completed?).and_return(true)
          end

          it 'should return enabled button' do
            expect(helper.response_options(response, [form]).split("</a>").last.include?('disabled')).to eq(false)
          end
        end

        context 'user is a service provider for surveyable' do
          let!(:sp) { create(:service_provider, organization: organization, identity: @user) }

          before :each do
            allow(response).to receive(:completed?).and_return(true)
          end

          it 'should return enabled button' do
            expect(helper.response_options(response, [form]).split("</a>").last.include?('disabled')).to eq(false)
          end
        end

        context 'user is not a super user or service provider for surveyable' do
          before :each do
            allow(response).to receive(:completed?).and_return(true)
          end

          it 'should return disabled button' do
            expect(helper.response_options(response, []).split("</a>").last.include?('disabled')).to eq(true)
          end
        end

        context 'response is incomplete' do
          before :each do
            allow(response).to receive(:completed?).and_return(false)
          end

          it 'should return disabled button' do
            expect(helper.response_options(response, []).split("</a>").last.include?('disabled')).to eq(true)
          end
        end
      end
    end
  end
end
