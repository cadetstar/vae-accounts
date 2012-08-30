class AddShortNameToDepartments < ActiveRecord::Migration
  def change
    add_column :departments, :short_name, :string
  end
end
