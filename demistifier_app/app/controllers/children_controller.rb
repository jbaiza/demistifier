class ChildrenController < ApplicationController
  before_action :set_child, only: [:show]

  # GET /children/1
  # GET /children/1.json
  def show
  end

  def search
    if request.post?
      @child = Child.find_by(child_uid: params[:child_uid])
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_child
      @child = Child.find(params[:id])
    end
end
