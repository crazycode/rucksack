class CreateCodes < ActiveRecord::Migration
  def self.up
    create_table :codes do |t|
      t.integer :page_id
      t.string :title
      t.text :content
      t.integer :created_by_id
      t.integer :updated_by_id

      t.timestamps
    end
  end

  def self.down
    drop_table :codes
  end
end
