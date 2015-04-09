class AddIndexToTagLabels < ActiveRecord::Migration
  def change
    add_index(:tags, :label, name: 'label_search')
  end
end
