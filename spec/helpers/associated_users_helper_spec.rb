# Copyright © 2011-2019 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require 'rails_helper'

RSpec.describe AssociatedUsersHelper, type: :helper do
  describe '#new_authorized_user_button' do
    context 'in dashboard' do
      before(:each) { allow(helper).to receive(:in_dashboard?).and_return(true) }

      context 'with permissions' do
        it 'should render the button' do
          expect(helper).to receive(:link_to).with(new_dashboard_associated_user_path(protocol_id: 1), any_args)
          helper.new_authorized_user_button(permission: true, protocol_id: 1)
        end
      end

      context 'without permissions' do
        it 'should not render the button' do
          expect(helper.new_authorized_user_button(permission: false, protocol_id: 1)).to be_nil
        end
      end
    end

    context 'not in dashboard' do
      before(:each) { allow(helper).to receive(:in_dashboard?).and_return(false) }

      it 'should render the button' do
        expect(helper).to receive(:link_to).with(new_associated_user_path(srid: 1), any_args)
        helper.new_authorized_user_button(srid: 1)
      end
    end
  end



  describe '#edit_authorized_user_button' do
    let(:project_role) { create(:project_role_without_validations) }

    context 'in dashboard' do
      before(:each) { allow(helper).to receive(:in_dashboard?).and_return(true) }

      context 'with permissions' do
        it 'should render the button' do
          expect(helper).to receive(:link_to).with(anything, edit_dashboard_associated_user_path(project_role), any_args)
          helper.edit_authorized_user_button(project_role, permission: true)
        end
      end

      context 'without permissions' do
        it 'should not render the button' do
          expect(helper.edit_authorized_user_button(project_role, permission: false)).to be_nil
        end
      end
    end

    context 'not in dashboard' do
      before(:each) { allow(helper).to receive(:in_dashboard?).and_return(false) }

      it 'should render the button' do
        expect(helper).to receive(:link_to).with(anything, edit_associated_user_path(project_role, srid: 1), any_args)
        helper.edit_authorized_user_button(project_role, srid: 1)
      end
    end
  end



  describe '#delete_authorized_user_button' do
    let(:project_role) { create(:project_role_without_validations) }

    context 'in dashboard' do
      before(:each) { allow(helper).to receive(:in_dashboard?).and_return(true) }

      context 'with permissions' do
        it 'should render the button' do
          ActionView::Base.send(:define_method, :current_user) { FactoryBot.create(:identity) }
          expect(helper).to receive(:button_tag).with(any_args)
          helper.delete_authorized_user_button(project_role, permission: true)
        end

        context 'deleting current user' do
          context 'user is an admin' do
            before(:each) do
              organization  = create(:organization)
              identity      = create(:identity, catalog_overlord: false)
                              create(:super_user, identity: identity, organization: organization)

              project_role.identity_id = identity.id
              ActionView::Base.send(:define_method, :current_user) { identity }
            end

            it 'should show the self-remove warning' do
              expect(helper.delete_authorized_user_button(project_role, permission: true, admin: true).include?(I18n.t('authorized_users.delete.self_remove_warning'))).to eq(true)
            end
          end

          context 'user is a catalog overlord' do
            before(:each) do
              identity                  = create(:identity, catalog_overlord: true)
              project_role.identity_id  = identity.id

              ActionView::Base.send(:define_method, :current_user) { identity }
            end

            it 'should show the self-remove warning' do
              expect(helper.delete_authorized_user_button(project_role, permission: true, admin: true).include?(I18n.t('authorized_users.delete.self_remove_warning'))).to eq(true)
            end
          end

          context 'user is a general user' do
            before(:each) do
              identity = create(:identity, catalog_overlord: false)

              project_role.identity_id = identity.id
              ActionView::Base.send(:define_method, :current_user) { identity }
            end

            it 'should show the self-remove redirect warning' do
              expect(helper.delete_authorized_user_button(project_role, permission: true, admin: false).include?(I18n.t('authorized_users.delete.self_remove_redirect_warning'))).to eq(true)
            end
          end
        end
      end

      context 'without permissions' do
        it 'should not render the button' do
          expect(helper.delete_authorized_user_button(project_role, permission: false)).to be_nil
        end
      end
    end

    context 'not in dashboard' do
      before(:each) { allow(helper).to receive(:in_dashboard?).and_return(false) }

      it 'should render the button' do
        ActionView::Base.send(:define_method, :current_user) { FactoryBot.create(:identity) }
        expect(helper).to receive(:button_tag).with(any_args)
        helper.delete_authorized_user_button(project_role, srid: 1)
      end

      context 'deleting current user' do
        context 'user is a catalog overlord' do
          before(:each) do
            identity                  = create(:identity, catalog_overlord: true)
            project_role.identity_id  = identity.id

            ActionView::Base.send(:define_method, :current_user) { identity }
          end

          it 'should show the self-remove warning' do
            expect(helper.delete_authorized_user_button(project_role).include?(I18n.t('authorized_users.delete.self_remove_warning'))).to eq(true)
          end
        end

        context 'user is a general user' do
          before(:each) do
            identity = create(:identity, catalog_overlord: false)

            project_role.identity_id = identity.id
            ActionView::Base.send(:define_method, :current_user) { identity }
          end

          it 'should show the self-remove redirect warning' do
            expect(helper.delete_authorized_user_button(project_role).include?(I18n.t('authorized_users.delete.self_remove_redirect_warning'))).to eq(true)
          end
        end
      end
    end

    context 'user is the Primary PI' do
      before(:each) do
        project_role.role = 'primary-pi'

        ActionView::Base.send(:define_method, :current_user) { FactoryBot.create(:identity) }
      end

      it 'should return a disabled button' do
        expect(helper.delete_authorized_user_button(project_role).include?('disabled')).to eq(true)
      end
    end
  end

  # TODO: Consider specs for professional organizations helpers
end
