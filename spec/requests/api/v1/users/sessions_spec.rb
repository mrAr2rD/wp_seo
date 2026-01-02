# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'api/v1/users/sessions', type: :request do
  path '/api/v1/users/sign_in' do
    post('Sign in user') do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, example: 'user@example.com' },
              password: { type: :string, example: 'password123' }
            },
            required: ['email', 'password']
          }
        },
        required: ['user']
      }

      response(200, 'successful') do
        let(:user_record) { User.create!(email: 'test@example.com', password: 'password123', name: 'Test User') }
        let(:user) { { user: { email: 'test@example.com', password: 'password123' } } }

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
          expect(response.headers['Authorization']).to be_present
        end
      end

      response(401, 'unauthorized') do
        let(:user) { { user: { email: 'wrong@example.com', password: 'wrongpassword' } } }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end

        run_test!
      end
    end
  end

  path '/api/v1/users/sign_out' do
    delete('Sign out user') do
      tags 'Authentication'
      security [{ Bearer: [] }]
      produces 'application/json'

      response(200, 'successful') do
        let(:user_record) { User.create!(email: 'test@example.com', password: 'password123', name: 'Test User') }
        let(:Authorization) do
          post '/api/v1/users/sign_in', params: { user: { email: 'test@example.com', password: 'password123' } }
          response.headers['Authorization']
        end

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end

        run_test!
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid_token' }

        run_test!
      end
    end
  end
end
