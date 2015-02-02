class AddTypeToSource < ActiveRecord::Migration
  def change
    add_column(:sources, :kind, :string)

    Source.all.each do |s|
      s.kind = "url" if !s.url.nil?
      s.save
    end
  end
end
