# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'api/v1/plans', type: :request do
  let(:user_record) { User.create!(email: 'test@example.com', password: 'password123', name: 'Test User') }
  let(:Authorization) do
    post '/api/v1/users/sign_in', params: { user: { email: 'test@example.com', password: 'password123' } }
    response.headers['Authorization']
  end

  path '/api/v1/plans' do
    get('List plans') do
      tags 'Plans'
      security [{ Bearer: [] }]
      produces 'application/json'

      response(200, 'successful') do
        let!(:plan) do
          Plan.create!(
            name: 'Basic Plan',
            price: 29.99,
            stripe_price_id: 'price_123',
            max_projects: 5,
            max_articles: 50,
            active: true
          )
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

  path '/api/v1/plans/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'Plan ID'

    get('Show plan') do
      tags 'Plans'
      security [{ Bearer: [] }]
      produces 'application/json'

      response(200, 'successful') do
        let(:plan) do
          Plan.create!(
            name: 'Basic Plan',
            price: 29.99,
            stripe_price_id: 'price_123',
            max_projects: 5,
            max_articles: 50,
            active: true
          )
        end
        let(:id) { plan.id }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end

        run_test!
      end

      response(404, 'not found') do
        let(:id) { 99999 }

        run_test!
      end
    end
  end
end
