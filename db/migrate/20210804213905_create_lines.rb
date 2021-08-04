class CreateLines < ActiveRecord::Migration[6.1]
  def change
    create_table :lines do |t|
      t.string :text
      t.belongs_to :song
      t.timestamps
    end
  end
end
