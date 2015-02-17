class RenameUrlToInput < ActiveRecord::Migration
  def change
    rename_column(:sources, :url, :input)
  end
end
