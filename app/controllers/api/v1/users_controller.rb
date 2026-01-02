module Api
  module V1
    class UsersController < BaseController
      def show
        render json: UserSerializer.new(current_api_v1_user).serializable_hash[:data][:attributes]
      end
    end
  end
end
