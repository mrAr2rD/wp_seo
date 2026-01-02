module Admin
  class DashboardController < BaseController
    def index
      render json: {
        total_users: User.count,
        active_subscriptions: Subscription.active.count,
        total_projects: Project.count,
        recent_users: User.order(created_at: :desc).limit(10).as_json(only: [:id, :email, :name, :created_at])
      }
    end
  end
end
