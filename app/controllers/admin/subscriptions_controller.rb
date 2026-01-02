module Admin
  class SubscriptionsController < BaseController
    def index
      @subscriptions = Subscription.includes(:user, :plan).page(params[:page]).per(25)
      render json: @subscriptions.as_json(
        include: {
          user: { only: [:id, :email, :name] },
          plan: { only: [:id, :name, :price] }
        }
      )
    end

    def show
      @subscription = Subscription.includes(:user, :plan).find(params[:id])
      render json: @subscription.as_json(
        include: {
          user: { only: [:id, :email, :name] },
          plan: {}
        }
      )
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Subscription not found' }, status: :not_found
    end
  end
end
