class ChildrenController < ApplicationController
  before_action :set_child, only: [:show]

  # GET /children/1
  # GET /children/1.json
  def show
  end

  def search
    if time = session[:calculation_time]
      time = Time.parse(time)
      @month = time.month
      @year = time.year
    end
    if date = params[:date]
      @month = date[:month].to_i
      @year = date[:year].to_i
      if @month <= Date.today.month && @year == Date.today.year
        session[:calculation_time] = nil
        @month = nil
        @year = nil
      else
        session[:calculation_time] = Time.new(@year, @month, 1)
      end
    end
    if params[:uid] && params[:child_uid]
      @child_uid = params[:child_uid].upcase
      @child = Child.find_by(child_uid: @child_uid)
    elsif params[:initials] && params[:child_initials].present?
      @child_initials = params[:child_initials].upcase
      children_query = Child.where("child_uid LIKE ?", "#{@child_initials}%")
      if params[:institution_id]
        @institution_id = params[:institution_id].to_i
        children_query = children_query.joins(applications: [:institution_program_language]).
          where(institution_program_languages: {institution_id: @institution_id})
      end

      children_count = children_query.count
      puts children_count
      if children_count > 0 && children_count < 10
        @children = children_query.order(:child_uid)
      end
      if children_count >= 10 || @institution_id
        @institutions = Institution.select(:id, :name).distinct.joins(institution_program_languages: [applications: [:child]]).
          where("children.child_uid LIKE ?", "#{@child_initials}%")
      end
    end
  end

  def hint
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_child
      @child = Child.find(params[:id])
    end
end
