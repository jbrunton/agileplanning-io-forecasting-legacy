class IssuesController < ApplicationController
  before_action :set_issue, only: [:show]

  # GET /issues
  # GET /issues.json
  def index
    @issues = Project.find(params[:project_id]).issues
  end

  # GET /issues/1
  # GET /issues/1.json
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_issue
      @issue = Issue.find(params[:id])
    end
end
