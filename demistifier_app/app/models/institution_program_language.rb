class InstitutionProgramLanguage < ApplicationRecord
  belongs_to :institution

  def self.calculate_queue_size
    sql = "SELECT institution_program_language_id, COUNT(*) AS count " <<
      "FROM applications GROUP BY institution_program_language_id"
    ActiveRecord::Base.connection.execute(sql).each do |count|
      find_by(id: count['institution_program_language_id']).update(queue_size: count['count'])
    end
  end
end
