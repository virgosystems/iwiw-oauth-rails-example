class CreateIwiwUsers < ActiveRecord::Migration
  def self.up
    create_table :iwiw_users do |t|
      t.string :user_id
      t.string :token
      t.string :secret
      t.string :screen_name
      t.boolean :anonymous
      t.string :thumbnail_url

      t.timestamps
    end
  end

  def self.down
    drop_table :iwiw_users
  end
end
