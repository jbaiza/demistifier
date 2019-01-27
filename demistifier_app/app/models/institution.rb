class Institution < ApplicationRecord
  belongs_to :region
  has_many :institution_program_languages

  def full_url
    return unless url
    return url if url.starts_with? "http"
    "http://#{url}"
  end
end
