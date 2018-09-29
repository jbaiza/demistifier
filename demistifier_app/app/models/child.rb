class Child < ApplicationRecord
  has_many :applications

  def min_waiting_time
    applications.map{|a| a.waiting_time}.min
  end
end
