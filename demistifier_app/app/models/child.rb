class Child < ApplicationRecord
  has_many :applications

  def min_waiting_time
    applications.map{|a| a.waiting_time}.min
  end

  def get_applications_calculated(session)
    calculated_applications = applications
    calculated_applications.each do |app|
      app.real_queue_position = app.real_queue_position_calculated(session)
    end
    calculated_applications
  end
end
