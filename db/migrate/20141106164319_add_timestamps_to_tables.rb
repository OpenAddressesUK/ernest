class AddTimestampsToTables < ActiveRecord::Migration
  def change
    add_column(:addresses, :created_at, :datetime)
    add_column(:addresses, :updated_at, :datetime)

    add_column(:tags, :created_at, :datetime)
    add_column(:tags, :updated_at, :datetime)

    add_column(:tag_types, :created_at, :datetime)
    add_column(:tag_types, :updated_at, :datetime)

    add_column(:addresses_tags, :created_at, :datetime)
    add_column(:addresses_tags, :updated_at, :datetime)

    add_column(:activities, :created_at, :datetime)
    add_column(:activities, :updated_at, :datetime)

    add_column(:derivations, :created_at, :datetime)
    add_column(:derivations, :updated_at, :datetime)

    add_column(:sources, :created_at, :datetime)
    add_column(:sources, :updated_at, :datetime)
  end
end
