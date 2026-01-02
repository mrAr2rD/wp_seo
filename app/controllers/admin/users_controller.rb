module Admin
  class UsersController < BaseController
    def index
      @users = User.includes(:subscription).page(params[:page]).per(25)
      render json: @users.as_json(
        include: {
          subscription: {
            include: :plan
          }
        }
      )
    end

    def show
      @user = User.includes(:subscription, :projects).find(params[:id])
      render json: @user.as_json(
        include: {
          subscription: { include: :plan },
          projects: { only: [:id, :name, :url, :status] }
        }
      )
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'User not found' }, status: :not_found
    end

    def update
      @user = User.find(params[:id])

      if @user.update(user_params)
        render json: @user
      else
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'User not found' }, status: :not_found
    end

    private

    def user_params
      params.require(:user).permit(:name, :email, :admin)
    end
  end
end
