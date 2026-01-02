module Api
  module V1
    class PlansController < ApplicationController
      skip_before_action :authenticate_api_v1_user!, only: [:index, :show]

      def index
        @plans = Plan.all
        render json: @plans
      end

      def show
        @plan = Plan.find(params[:id])
        render json: @plan
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Plan not found' }, status: :not_found
      end
    end
  end
end
