class CreatePlans < ActiveRecord::Migration[8.0]
  def change
    create_table :plans do |t|
      t.string :name
      t.decimal :price
      t.json :features
      t.string :stripe_price_id
      t.integer :max_projects
      t.integer :max_articles

      t.timestamps
    end
  end
end
