# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'api/v1/users', type: :request do
  let(:user_record) { User.create!(email: 'test@example.com', password: 'password123', name: 'Test User') }
  let(:Authorization) do
    post '/api/v1/users/sign_in', params: { user: { email: 'test@example.com', password: 'password123' } }
    response.headers['Authorization']
  end

  path '/api/v1/current_user' do
    get('Get current user') do
      tags 'Users'
      security [{ Bearer: [] }]
      produces 'application/json'

      response(200, 'successful') do
        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('data')
          expect(data['data']['id']).to eq(user_record.id.to_s)
        end
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid_token' }

        run_test!
      end
    end
  end
end
