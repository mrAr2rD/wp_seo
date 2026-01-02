# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'api/v1/users/registrations', type: :request do
  path '/api/v1/users' do
    post('Create user') do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, example: 'newuser@example.com' },
              password: { type: :string, example: 'password123' },
              password_confirmation: { type: :string, example: 'password123' },
              name: { type: :string, example: 'New User' }
            },
            required: ['email', 'password', 'password_confirmation']
          }
        },
        required: ['user']
      }

      response(201, 'created') do
        let(:user) do
          {
            user: {
              email: 'newuser@example.com',
              password: 'password123',
              password_confirmation: 'password123',
              name: 'New User'
            }
          }
        end

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

      response(422, 'unprocessable entity') do
        let(:user) do
          {
            user: {
              email: 'invalid',
              password: 'short',
              password_confirmation: 'different'
            }
          }
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
    end
  end
end
