class Institution < ApplicationRecord
  belongs_to :region
  has_many :institution_program_languages
end
