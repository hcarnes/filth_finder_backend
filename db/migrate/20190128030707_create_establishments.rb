class CreateEstablishments < ActiveRecord::Migration[5.2]
  def change
    create_table :establishments do |t|
      t.text :camis, null: false, unique: true
      t.text :address
      t.text :dba
      t.st_point :location, geographic: true

      t.timestamps
    end
  end
end
