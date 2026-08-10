class EnumifyPatient < ActiveRecord::Migration[5.0]
  def change
    reversible do |dir|
      dir.up do
        change_column :pat_patients, :marital_status, 'integer USING CAST("marital_status" AS integer)'
        change_column :pat_patients, :status,'integer USING CAST("status" AS integer)'
        change_column :pat_patients, :race,'integer USING CAST("race" AS integer)'
        change_column :pat_patients, :ethnicity,'integer USING CAST("ethnicity" AS integer)'
        change_column :pat_patients, :language,'integer USING CAST("language" AS integer)'
      end

      dir.down do
        change_column :pat_patients, :marital_status, 'character varying USING CAST("marital_status" AS character varying)'
        change_column :pat_patients, :status,'character varying USING CAST("status" AS character varying)'
        change_column :pat_patients, :race,'character varying USING CAST("race" AS character varying)'
        change_column :pat_patients, :ethnicity,'character varying USING CAST("ethnicity" AS character varying)'
        change_column :pat_patients, :language,'character varying USING CAST("language" AS character varying)'
      end
    end
  end
end
