# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'api/v1/projects', type: :request do
  let(:user_record) { User.create!(email: 'test@example.com', password: 'password123', name: 'Test User') }
  let(:Authorization) do
    post '/api/v1/users/sign_in', params: { user: { email: 'test@example.com', password: 'password123' } }
    response.headers['Authorization']
  end

  path '/api/v1/projects' do
    get('List projects') do
      tags 'Projects'
      security [{ Bearer: [] }]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'

      response(200, 'successful') do
        let(:page) { 1 }

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
        let(:page) { 1 }

        run_test!
      end
    end

    post('Create project') do
      tags 'Projects'
      security [{ Bearer: [] }]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :project, in: :body, schema: {
        type: :object,
        properties: {
          project: {
            type: :object,
            properties: {
              name: { type: :string, example: 'My WordPress Site' },
              url: { type: :string, example: 'https://mysite.com' },
              wordpress_api_key: { type: :string, example: 'wp_api_key_123' }
            },
            required: ['name', 'url', 'wordpress_api_key']
          }
        },
        required: ['project']
      }

      response(201, 'created') do
        let(:project) do
          {
            project: {
              name: 'Test Project',
              url: 'https://testsite.com',
              wordpress_api_key: 'test_key_123'
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

      response(422, 'unprocessable entity') do
        let(:project) do
          {
            project: {
              name: '',
              url: 'invalid_url',
              wordpress_api_key: ''
            }
          }
        end

        run_test!
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid_token' }
        let(:project) do
          {
            project: {
              name: 'Test Project',
              url: 'https://testsite.com',
              wordpress_api_key: 'test_key_123'
            }
          }
        end

        run_test!
      end
    end
  end

  path '/api/v1/projects/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'Project ID'

    get('Show project') do
      tags 'Projects'
      security [{ Bearer: [] }]
      produces 'application/json'

      response(200, 'successful') do
        let(:project_record) { user_record.projects.create!(name: 'Test', url: 'https://test.com', wordpress_api_key: 'key') }
        let(:id) { project_record.id }

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

    patch('Update project') do
      tags 'Projects'
      security [{ Bearer: [] }]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :project, in: :body, schema: {
        type: :object,
        properties: {
          project: {
            type: :object,
            properties: {
              name: { type: :string },
              url: { type: :string },
              status: { type: :string, enum: ['active', 'inactive', 'pending'] }
            }
          }
        }
      }

      response(200, 'successful') do
        let(:project_record) { user_record.projects.create!(name: 'Test', url: 'https://test.com', wordpress_api_key: 'key') }
        let(:id) { project_record.id }
        let(:project) { { project: { name: 'Updated Name' } } }

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
        let(:project) { { project: { name: 'Updated Name' } } }

        run_test!
      end
    end

    delete('Delete project') do
      tags 'Projects'
      security [{ Bearer: [] }]
      produces 'application/json'

      response(204, 'no content') do
        let(:project_record) { user_record.projects.create!(name: 'Test', url: 'https://test.com', wordpress_api_key: 'key') }
        let(:id) { project_record.id }

        run_test!
      end

      response(404, 'not found') do
        let(:id) { 99999 }

        run_test!
      end
    end
  end

  path '/api/v1/projects/{id}/validate_wordpress' do
    parameter name: :id, in: :path, type: :integer, description: 'Project ID'

    post('Validate WordPress connection') do
      tags 'Projects'
      security [{ Bearer: [] }]
      produces 'application/json'

      response(200, 'successful') do
        let(:project_record) { user_record.projects.create!(name: 'Test', url: 'https://test.com', wordpress_api_key: 'key') }
        let(:id) { project_record.id }

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
