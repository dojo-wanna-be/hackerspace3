class Admin::TeamsController < ApplicationController
  before_action :authenticate_user!, :check_for_privileges!
  before_action :retrieve_team, except: :index

  def index
    @projects = @competition.projects_by_name.preload(:event, :team)
    handle_index
  end

  def show
    @project = @team.current_project
    @projects = @team.projects
    @event = @team.event
    @region = @team.region
    @checkpoints = @competition.checkpoints.order :end_time
    @available_regional_challenges = @team.available_challenges REGIONAL
    @available_national_challenges = @team.available_challenges NATIONAL
  end

  def update_version
    @project = Project.find params[:project_id]
    @team.update current_project: @project
    flash[:notice] = 'Current Project Version Updated'
    redirect_to admin_team_project_path @team, @project
  end

  def update_published
    @team.update published: params[:published]
    flash[:notice] = 'Team ' + (@team.published ? 'published' : 'unpublished')
    redirect_to admin_competition_team_path @competition, @team
  end

  private

  def check_for_privileges!
    @competition = Competition.find params[:competition_id]
    return if current_user.admin_privileges? @competition

    flash[:alert] = 'You must have valid assignments to access this section.'
    redirect_to root_path
  end

  def retrieve_team
    @team = Team.find params[:id]
  end

  def handle_index
    respond_to do |format|
      format.html
      if params[:category] == 'members'
        format.csv { send_data User.all_members_to_csv @competition }
      else
        format.csv { send_data User.published_teams_to_csv @competition }
      end
    end
  end
end
