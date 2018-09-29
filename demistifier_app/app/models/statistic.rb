class Statistic < ApplicationRecord
  belongs_to :institution
  belongs_to :region
  belongs_to :statistic_measure
end
