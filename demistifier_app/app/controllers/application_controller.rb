class ApplicationController < ActionController::Base
  before_action :initialize_session

  def initialize_session
    session[:data_reload_time] ||=
      begin
        Statistic.find_by(statistic_measure_id: StatisticMeasure.find_by(code: "DATA_RELOAD_DATE")).value_date.to_date
      end
    if @data_reload_time = session[:data_reload_time]
      @data_reload_time = Date.parse(@data_reload_time) if @data_reload_time.is_a? String
    end
  end
end
