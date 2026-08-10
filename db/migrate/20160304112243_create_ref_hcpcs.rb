class CreateRefHcpcs < ActiveRecord::Migration
  def change
    create_table :ref_hcpcs do |t|
      t.string :code,                         limit: 5,  null: false
      t.string :code_redef_group,             limit: 5
      t.string :filler1,                      limit: 3
      t.string :modifier_code,                limit: 2
      t.string :seq_number,                   limit: 5
      t.string :record_identification_code,   limit: 1
      t.string :description,                  limit: 80
      t.string :short_description,            limit: 28
      t.string :pricing_indicator_code,       limit: 2
      t.string :mult_pricing_indicator_code,  limit: 1
      t.string :issues_ref_section,           limit: 6
      t.string :carriers_ref_section,         limit: 8
      t.string :statute_number,               limit: 10
      t.string :lab_cert_code,                limit: 3
      t.string :cross_reference_code,         limit: 5
      t.string :coverage_code,                limit: 1
      t.string :payment_group_code,           limit: 2
      t.string :payment_group_effective_date, limit: 8
      t.string :mog_payment_group_code,       limit: 3
      t.string :mog_payment_policy_indicator, limit: 1
      t.string :mog_effective_date,           limit: 8
      t.string :process_note_number,          limit: 4
      t.string :berenson_eggers_tos_code,     limit: 3
      t.string :filler2,                      limit: 1
      t.string :tos_code,                     limit: 1
      t.string :anesthesia_base_unit_qty,     limit: 3
      t.string :code_added_date,              limit: 8
      t.string :effective_date,               limit: 8
      t.string :termination_date,             limit: 8
      t.string :action_code,                  limit: 1
      t.string :filler3,                      limit: 27

      t.timestamps null: false
    end

    add_index :ref_hcpcs, :code
  end
end
