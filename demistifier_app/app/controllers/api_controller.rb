class ApiController < ApplicationController
  def applications_with_start_date_in_past
    results = ActiveRecord::Base.connection.execute(<<-SQL)
      SELECT date_trunc('month', desirable_start_date) as month, count(*) as application_count
      FROM applications
      WHERE desirable_start_date < CURRENT_DATE
      GROUP BY date_trunc('month', desirable_start_date)
      ORDER BY 1
    SQL
    count = results.map do |row|
      {month: row["month"], count: row["application_count"]}
    end
    render json: count, status: :ok
  end

  def applications_totals
    results = ActiveRecord::Base.connection.execute(<<-SQL)
      SELECT COUNT(DISTINCT CASE WHEN nanny_fin_local OR private_fin_local THEN child_Id ELSE NULL END) AS private_or_nanny,
        COUNT(DISTINCT CASE WHEN desirable_start_date <= CURRENT_DATE THEN child_id ELSE NULL END) AS actual_queue,
        COUNT(DISTINCT CASE WHEN desirable_start_date > CURRENT_DATE THEN child_id ELSE NULL END) AS future_queue
      FROM applications_old
    SQL
    render json: results, status: :ok
  end
end
