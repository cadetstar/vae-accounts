class AddClassificationToDepartments < ActiveRecord::Migration
  def change
    add_column :departments, :classification, :string
  end
end
