class AddAvgInvitedToInstitutionProgramLanguages < ActiveRecord::Migration[5.2]
  def change
    add_column :institution_program_languages, :avg_invited, :float
  end
end
