class AddUser < ActiveRecord::Migration
  def change
    create_table :users, :options => 'ENGINE=MyISAM' do |t|
      t.string :name
      t.string :email
      t.string :api_key
    end

    add_column :addresses, :user_id, :integer
  end
end
