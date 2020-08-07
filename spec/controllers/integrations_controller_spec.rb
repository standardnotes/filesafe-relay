# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IntegrationsController, type: :controller do
  describe 'download_failure' do
    it 'should signal integration failure' do
      post :download_item

      expect(response).to have_http_status(:bad_request)
      expect(response.headers['Content-Type']).to eq(
        'application/json; charset=utf-8'
      )

      parsed_response_body = JSON.parse(response.body)

      expect(parsed_response_body).to_not be_nil
      expect(parsed_response_body['error']).to_not be_nil
      expect(parsed_response_body['error']['message']).to eq(
        'Could not retrieve item. Please verify your integration.'
      )
    end
  end

  describe 'save_failure' do
    it 'should signal integration failure' do
      post :save_item

      expect(response).to have_http_status(:bad_request)
      expect(response.headers['Content-Type']).to eq(
        'application/json; charset=utf-8'
      )

      parsed_response_body = JSON.parse(response.body)

      expect(parsed_response_body).to_not be_nil
      expect(parsed_response_body['error']).to_not be_nil
      expect(parsed_response_body['error']['message']).to eq(
        'Could not save item. Please verify your integration.'
      )
    end
  end

  describe 'delete_failure' do
    it 'should signal integration failure' do
      post :delete_item

      expect(response).to have_http_status(:bad_request)
      expect(response.headers['Content-Type']).to eq(
        'application/json; charset=utf-8'
      )

      parsed_response_body = JSON.parse(response.body)

      expect(parsed_response_body).to_not be_nil
      expect(parsed_response_body['error']).to_not be_nil
      expect(parsed_response_body['error']['message']).to eq(
        'Could not delete item. Please verify your integration.'
      )
    end
  end
end
