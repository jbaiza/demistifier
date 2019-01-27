class Statistic < ApplicationRecord
  belongs_to :institution, optional: true
  belongs_to :region, optional: true
  belongs_to :statistic_measure, optional: true
end
