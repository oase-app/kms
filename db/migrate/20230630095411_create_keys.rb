class CreateKeys < ActiveRecord::Migration[7.0]
  def change
    enable_extension 'pgcrypto'
    create_table :keys, id: :uuid do |t|
      t.string :oase_id
      t.string :value
      t.string :issuer

      t.timestamps

      t.index :oase_id
    end
  end
end
