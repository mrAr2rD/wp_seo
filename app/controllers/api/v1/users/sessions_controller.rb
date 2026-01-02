module Api
  module V1
    module Users
      class SessionsController < Devise::SessionsController
        skip_before_action :verify_authenticity_token
        wrap_parameters false
        respond_to :json

        def create
          user = User.find_by(email: params[:user][:email])

          if user&.valid_password?(params[:user][:password])
            sign_in(:user, user)
            render json: {
              message: "Logged in successfully.",
              user: UserSerializer.new(user).serializable_hash[:data][:attributes]
            }, status: :ok
          else
            render json: { error: 'Invalid email or password' }, status: :unauthorized
          end
        end

        private

        def respond_with(resource, _opts = {})
          render json: {
            message: "Logged in successfully.",
            user: UserSerializer.new(resource).serializable_hash[:data][:attributes]
          }, status: :ok
        end

        def respond_to_on_destroy
          if current_api_v1_user
            render json: {
              message: "Logged out successfully."
            }, status: :ok
          else
            render json: {
              message: "Couldn't find an active session."
            }, status: :unauthorized
          end
        end
      end
    end
  end
end
