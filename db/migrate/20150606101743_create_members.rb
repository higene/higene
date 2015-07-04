class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.belongs_to :user, index: true
      t.belongs_to :workspace, index: true
      t.string :role, null: false
      t.timestamps null: false
    end
  end
end
