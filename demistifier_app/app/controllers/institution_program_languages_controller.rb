class InstitutionProgramLanguagesController < ApplicationController
  before_action :set_institution_program_language, only: [:show]

  # GET /institution_program_languages/1
  # GET /institution_program_languages/1.json
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_institution_program_language
      @institution_program_language = InstitutionProgramLanguage.find(params[:id])
    end
end
