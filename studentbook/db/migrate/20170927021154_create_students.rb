class CreateStudents < ActiveRecord::Migration[5.1]
  def change
    create_table :students do |t|
      t.string :name
      t.string :phone
      t.string :town
      t.string :course
      t.boolean :paid_tuition

      t.timestamps
    end
  end
end
