class CreateRepos < ActiveRecord::Migration
  def change
    create_table :repos do |t|
      t.string :name
      t.string :protocol
      t.string :url

      t.timestamps
    end

    add_index :repos, :name, unique: true
  end
end
