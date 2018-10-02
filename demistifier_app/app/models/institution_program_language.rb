class InstitutionProgramLanguage < ApplicationRecord
  belongs_to :institution
  has_many :applications
  has_many :statistics

  def self.calculate_queue_size
    sql = "SELECT institution_program_language_id, COUNT(*) AS count " <<
      "FROM applications GROUP BY institution_program_language_id"
    ActiveRecord::Base.connection.execute(sql).each do |count|
      find_by(id: count['institution_program_language_id']).update(queue_size: count['count'])
    end
  end

  def self.calculate_average_invited
    measure_id = StatisticMeasure.find_by(code: 'INVITED').id
    InstitutionProgramLanguage.all.each do |program_language|
      sum = 0
      count = 0
      program_language.statistics.where(statistic_measure_id: measure_id).
          where("year BETWEEN ? AND ?", Time.now.year - 4, Time.now.year - 1).each do |stat|
        if (value = stat['value']) > 0
          sum += value
          count += 1
        end
      end
      program_language.update(avg_invited: sum / count) if count > 0
    end
  end

  def get_applications_calculated(session)
    calculated_applications = applications
    Application.calculate_program_applications_real_queue_position(calculated_applications, session)
    calculated_applications
  end
end
