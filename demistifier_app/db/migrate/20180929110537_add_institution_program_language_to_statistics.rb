class AddInstitutionProgramLanguageToStatistics < ActiveRecord::Migration[5.2]
  def change
    add_reference :statistics, :institution_program_language, foreign_key: true
  end
end
