# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'api/v1/subscriptions', type: :request do
  let(:user_record) { User.create!(email: 'test@example.com', password: 'password123', name: 'Test User', stripe_customer_id: 'cus_123') }
  let(:Authorization) do
    post '/api/v1/users/sign_in', params: { user: { email: 'test@example.com', password: 'password123' } }
    response.headers['Authorization']
  end
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

  path '/api/v1/subscriptions' do
    get('List user subscriptions') do
      tags 'Subscriptions'
      security [{ Bearer: [] }]
      produces 'application/json'

      response(200, 'successful') do
        let!(:subscription) do
          user_record.create_subscription!(
            plan: plan,
            status: 'active',
            stripe_subscription_id: 'sub_123'
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

    post('Create subscription') do
      tags 'Subscriptions'
      security [{ Bearer: [] }]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :subscription, in: :body, schema: {
        type: :object,
        properties: {
          plan_id: { type: :integer, example: 1 },
          payment_method_id: { type: :string, example: 'pm_card_visa' }
        },
        required: ['plan_id', 'payment_method_id']
      }

      response(201, 'created') do
        let(:subscription) do
          {
            plan_id: plan.id,
            payment_method_id: 'pm_card_visa'
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

      response(422, 'unprocessable entity') do
        let(:subscription) do
          {
            plan_id: 99999,
            payment_method_id: 'invalid'
          }
        end

        run_test!
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid_token' }
        let(:subscription) do
          {
            plan_id: plan.id,
            payment_method_id: 'pm_card_visa'
          }
        end

        run_test!
      end
    end
  end

  path '/api/v1/subscriptions/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'Subscription ID'

    patch('Update subscription') do
      tags 'Subscriptions'
      security [{ Bearer: [] }]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :subscription, in: :body, schema: {
        type: :object,
        properties: {
          plan_id: { type: :integer }
        }
      }

      response(200, 'successful') do
        let(:new_plan) do
          Plan.create!(
            name: 'Pro Plan',
            price: 49.99,
            stripe_price_id: 'price_456',
            max_projects: 10,
            max_articles: 100,
            active: true
          )
        end
        let(:subscription_record) do
          user_record.create_subscription!(
            plan: plan,
            status: 'active',
            stripe_subscription_id: 'sub_123'
          )
        end
        let(:id) { subscription_record.id }
        let(:subscription) { { plan_id: new_plan.id } }

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
        let(:subscription) { { plan_id: plan.id } }

        run_test!
      end
    end

    delete('Cancel subscription') do
      tags 'Subscriptions'
      security [{ Bearer: [] }]
      produces 'application/json'

      response(200, 'successful') do
        let(:subscription_record) do
          user_record.create_subscription!(
            plan: plan,
            status: 'active',
            stripe_subscription_id: 'sub_123'
          )
        end
        let(:id) { subscription_record.id }

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

  path '/api/v1/subscriptions/webhook' do
    post('Stripe webhook') do
      tags 'Subscriptions'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :event, in: :body, schema: {
        type: :object,
        properties: {
          type: { type: :string, example: 'invoice.payment_succeeded' },
          data: {
            type: :object,
            properties: {
              object: {
                type: :object,
                properties: {
                  subscription: { type: :string, example: 'sub_123' }
                }
              }
            }
          }
        }
      }

      response(200, 'successful') do
        let(:event) do
          {
            type: 'invoice.payment_succeeded',
            data: {
              object: {
                subscription: 'sub_123'
              }
            }
          }
        end

        run_test!
      end
    end
  end
end
