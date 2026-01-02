module Api
  module V1
    class ArticlesController < BaseController
      before_action :set_project, only: [:index, :create]
      before_action :set_article, only: [:show, :update, :destroy, :publish]

      def index
        @articles = @project.generated_articles.order(created_at: :desc)
        render json: @articles
      end

      def show
        render json: @article
      end

      def create
        @article = @project.generated_articles.build(article_params)

        if @article.save
          # Queue article generation job
          ArticleGenerationWorker.perform_async(@article.id)
          render json: @article, status: :created
        else
          render json: { errors: @article.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @article.update(article_update_params)
          render json: @article
        else
          render json: { errors: @article.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @article.destroy
        head :no_content
      end

      def publish
        if @article.status != 'completed'
          return render json: { error: 'Article must be completed before publishing' }, status: :unprocessable_entity
        end

        WordpressPublishWorker.perform_async(@article.id)
        render json: { message: 'Article queued for publishing' }
      end

      private

      def set_project
        @project = current_api_v1_user.projects.find(params[:project_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Project not found' }, status: :not_found
      end

      def set_article
        @article = current_api_v1_user.projects.joins(:generated_articles)
                                      .find_by!(generated_articles: { id: params[:id] })
                                      .generated_articles.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Article not found' }, status: :not_found
      end

      def article_params
        params.require(:article).permit(:title, :gemini_prompt)
      end

      def article_update_params
        params.require(:article).permit(:title, :content, :gemini_prompt)
      end
    end
  end
end
