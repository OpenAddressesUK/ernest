class CreateAddressesTagsIndices < ActiveRecord::Migration
  def change
    add_index :addresses_tags, [:address_id, :tag_id]
    add_index :addresses_tags, :address_id
    add_index :addresses_tags, :tag_id
  end
end
