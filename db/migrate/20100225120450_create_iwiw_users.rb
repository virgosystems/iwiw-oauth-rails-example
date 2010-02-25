class CreateIwiwUsers < ActiveRecord::Migration
  def self.up
    create_table :iwiw_users do |t|
      t.integer :user_id
      t.string :token
      t.string :secret
      t.string :display_name
      t.string :thumbnail_url

      t.timestamps
    end
  end

  def self.down
    drop_table :iwiw_users
  end
end
