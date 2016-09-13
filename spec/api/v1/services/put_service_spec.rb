# Copyright © 2011-2016 MUSC Foundation for Research Development~
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

RSpec.describe 'SPARCCWF::APIv1', type: :request do

  describe 'PUT /v1/service/:id.json' do

    before do
      @service = create(:service)
    end

    context "success" do

      context "increment" do

        context 'response params' do

          before do
            service_params = {
              service: {
                line_items_count: 1
              }
            }

            cwf_sends_api_put_request_for_resource('services', @service.id, service_params)
          end

          context 'success' do

            it 'should respond with an HTTP status code of: 200' do
              expect(response.status).to eq(200)
            end

            it 'should respond with content-type: application/json' do
              expect(response.content_type).to eq('application/json')
            end

            it 'should respond with a Protocol root object' do
              expect(response.body).to match(/ok/)
            end

            it "should increment the Service.line_items_count" do
              expect(@service.reload.line_items_count).to eq(1)
            end
          end
        end
      end

      context "decrement" do

        context 'response params' do

          before do
            line_item = build(:line_item, service: @service)
            line_item.save validate: false

            service_params = {
              service: {
                line_items_count: -1
              }
            }

            cwf_sends_api_put_request_for_resource('services', @service.id, service_params)
          end

          context 'success' do

            it 'should respond with an HTTP status code of: 200' do
              expect(response.status).to eq(200)
            end

            it 'should respond with content-type: application/json' do
              expect(response.content_type).to eq('application/json')
            end

            it 'should respond with a Protocol root object' do
              expect(response.body).to match(/ok/)
            end

            it "should increment the Service.line_items_count" do
              expect(@service.reload.line_items_count).to eq(0)
            end
          end
        end
      end
    end

    context "failure" do

      describe "Service not found" do

        before do
          service_params = {
            service: {
              line_items_count: 1
            }
          }

          cwf_sends_api_put_request_for_resource('services', 999, service_params)
        end

        it 'should respond with an HTTP status code of: 404' do
          expect(response.status).to eq(404)
        end

        it 'should respond with content-type: application/json' do
          expect(response.content_type).to eq('application/json')
        end

        it 'should respond with a Protocol root object' do
          expect(response.body).to match(/not found/)
        end
      end

      describe "params[:service][:line_items_count] not present" do

        before do
          service_params = {
            service: {}
          }

          cwf_sends_api_put_request_for_resource('services', @service.id, service_params)
        end

        it 'should respond with an HTTP status code of: 400' do
          expect(response.status).to eq(400)
        end

        it 'should respond with content-type: application/json' do
          expect(response.content_type).to eq('application/json')
        end

        it 'should respond with a Protocol root object' do
          expect(response.body).to match(/Bad request/)
        end
      end
    end
  end
end
