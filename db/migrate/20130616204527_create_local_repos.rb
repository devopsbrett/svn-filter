class CreateLocalRepos < ActiveRecord::Migration
  def change
    create_table :local_repos do |t|
      t.references :repo
      t.string :path
      t.integer :status

      t.timestamps
    end
    add_index :local_repos, :repo_id
  end
end
