module Admin
  class BaseController < ApplicationController
    before_action :authenticate_api_v1_user!
    before_action :check_admin

    private

    def check_admin
      unless current_api_v1_user&.admin?
        render json: { error: 'Unauthorized' }, status: :forbidden
      end
    end
  end
end
