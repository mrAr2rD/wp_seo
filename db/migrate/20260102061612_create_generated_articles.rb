class CreateGeneratedArticles < ActiveRecord::Migration[8.0]
  def change
    create_table :generated_articles do |t|
      t.references :project, null: false, foreign_key: true
      t.string :title
      t.text :content
      t.string :status
      t.text :gemini_prompt
      t.datetime :published_at
      t.string :wordpress_post_id

      t.timestamps
    end
  end
end
