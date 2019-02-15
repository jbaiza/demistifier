class ApplicationHistory < ApplicationRecord
  belongs_to :institution_program_language
  belongs_to :child
end
