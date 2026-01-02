module Api
  module V1
    class ProjectsController < BaseController
      before_action :set_project, only: [:show, :update, :destroy, :validate_wordpress]

      def index
        @projects = current_api_v1_user.projects
        render json: @projects
      end

      def show
        render json: @project
      end

      def create
        @project = current_api_v1_user.projects.build(project_params)

        if @project.save
          render json: @project, status: :created
        else
          render_error(@project.errors.full_messages.join(', '))
        end
      end

      def update
        if @project.update(project_params)
          render json: @project
        else
          render_error(@project.errors.full_messages.join(', '))
        end
      end

      def destroy
        @project.destroy
        head :no_content
      end

      def validate_wordpress
        validator = WordpressValidator.new(@project)

        if validator.valid?
          @project.update(status: 'active')
          render json: { message: 'WordPress connection validated successfully', project: @project }
        else
          render_error(validator.error_message, :unprocessable_entity)
        end
      end

      private

      def set_project
        @project = current_api_v1_user.projects.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render_error('Project not found', :not_found)
      end

      def project_params
        params.require(:project).permit(:name, :url, :wordpress_api_key, :wordpress_username, :status)
      end
    end
  end
end
