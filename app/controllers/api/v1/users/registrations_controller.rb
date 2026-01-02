module Api
  module V1
    module Users
      class RegistrationsController < Devise::RegistrationsController
        skip_before_action :verify_authenticity_token
        wrap_parameters false
        respond_to :json

        private

        def sign_up_params
          params.require(:user).permit(:email, :password, :password_confirmation, :name)
        end

        def account_update_params
          params.require(:user).permit(:email, :password, :password_confirmation, :name, :current_password)
        end

        def respond_with(resource, _opts = {})
          if resource.persisted?
            render json: {
              message: "Signed up successfully.",
              user: UserSerializer.new(resource).serializable_hash[:data][:attributes]
            }, status: :ok
          else
            render json: {
              message: "User couldn't be created successfully.",
              errors: resource.errors.full_messages
            }, status: :unprocessable_entity
          end
        end
      end
    end
  end
end
