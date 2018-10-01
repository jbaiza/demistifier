class ChildrenController < ApplicationController
  before_action :set_child, only: [:show]

  # GET /children/1
  # GET /children/1.json
  def show
  end

  def search
    if params[:uid] && params[:child_uid]
      @child_uid = params[:child_uid].upcase
      @child = Child.find_by(child_uid: @child_uid)
    elsif params[:initials] && params[:child_initials]
      @child_initials = params[:child_initials].upcase
      children_query = Child.where("child_uid LIKE ?", "#{@child_initials}%")
      if params[:institution_id]
        @institution_id = params[:institution_id].to_i
        children_query = children_query.joins(applications: [:institution_program_language]).
          where(institution_program_languages: {institution_id: @institution_id})
      end

      children_count = children_query.count
      puts children_count
      if children_count < 10
        @children = children_query.order(:child_uid)
      end
      if children_count >= 10 || @institution_id
        @institutions = Institution.joins(institution_program_languages: [applications: [:child]]).
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
