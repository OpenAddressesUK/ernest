class AddFulltextIndexToTags < ActiveRecord::Migration
  def change
    add_index(:tags, :label, type: :fulltext)
  end
end
