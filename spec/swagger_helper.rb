# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.openapi_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a openapi_spec tag to the
  # the root example_group in your specs, e.g. describe '...', openapi_spec: 'v2/swagger.json'
  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'ContentFlow API',
        version: 'v1',
        description: 'API для управления WordPress проектами и подписками'
      },
      paths: {},
      servers: [
        {
          url: 'http://localhost:3000',
          description: 'Development server'
        },
        {
          url: 'https://api.contentflow.com',
          description: 'Production server'
        }
      ],
      components: {
        securitySchemes: {
          Bearer: {
            type: :http,
            scheme: :bearer,
            bearerFormat: 'JWT',
            description: 'JWT token obtained from /api/v1/users/sign_in'
          }
        },
        schemas: {
          User: {
            type: :object,
            properties: {
              id: { type: :integer },
              email: { type: :string },
              name: { type: :string },
              created_at: { type: :string, format: 'date-time' }
            }
          },
          Project: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string },
              url: { type: :string },
              status: { type: :string, enum: ['active', 'inactive', 'pending'] },
              created_at: { type: :string, format: 'date-time' }
            }
          },
          Plan: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string },
              price: { type: :number },
              max_projects: { type: :integer },
              max_articles: { type: :integer }
            }
          },
          Subscription: {
            type: :object,
            properties: {
              id: { type: :integer },
              status: { type: :string },
              plan_id: { type: :integer },
              user_id: { type: :integer },
              stripe_subscription_id: { type: :string }
            }
          },
          Error: {
            type: :object,
            properties: {
              error: { type: :string }
            }
          }
        }
      }
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :yaml
end
