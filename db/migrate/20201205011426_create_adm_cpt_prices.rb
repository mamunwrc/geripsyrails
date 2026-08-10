class CreateAdmCptPrices < ActiveRecord::Migration[5.1]
  def change
    create_table :adm_cpt_prices do |t|
      t.text :cpt_code, index: true
      t.money :price, scale: 2
    end
  end
end
