class CreateProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :projects do |t|
      t.references :user, null: false, foreign_key: true
      t.string :url
      t.text :wordpress_api_key
      t.string :wordpress_username
      t.string :name
      t.string :status

      t.timestamps
    end
  end
end
