class ChildrenController < ApplicationController
  before_action :set_child, only: [:show]

  # GET /children/1
  # GET /children/1.json
  def show
  end

  def search
    if request.post?
      params[:child_uid].upcase!
      child_uid = params[:child_uid]
      @child = Child.find_by(child_uid: child_uid)
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
