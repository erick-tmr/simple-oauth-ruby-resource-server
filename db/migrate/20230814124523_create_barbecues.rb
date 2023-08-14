class CreateBarbecues < ActiveRecord::Migration[7.0]
  def change
    create_table :barbecues do |t|
      t.references :owner, index: true, foreign_key: { to_table: :users }
      t.text :name
      t.text :workspace_id

      t.timestamps
    end
  end
end
