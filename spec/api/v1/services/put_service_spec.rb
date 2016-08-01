# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
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
