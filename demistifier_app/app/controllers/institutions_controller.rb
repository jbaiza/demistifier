class InstitutionsController < ApplicationController

  # GET /institutions
  # GET /institutions.json
  # GET /institutions.csv
  def index
    @institutions = Institution.includes(:region).all
    respond_to do |format|
      format.html
      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"insitutions.csv\""
        headers['Content-Type'] ||= 'text/csv'
      end
    end
  end

end
