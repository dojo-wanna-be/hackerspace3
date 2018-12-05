class TeamsController < ApplicationController
  def new
    @competition = Competition.current
    if user_signed_in? && helpers.in_competition_window?(LAST_TIME_ZONE)
      @team = Team.new
      @events = current_user.competition_events_participating(@competition)
      if @events.empty?
        flash[:alert] = 'To create a new team, first register for a competition event.'
        redirect_to events_path
      end
    elsif helpers.in_competition_window?(LAST_TIME_ZONE)
      flash[:alert] = 'To create a new team, first sign in.'
      redirect_to projects_path
    else
      flash[:alert] = 'The competition is now closed.'
      redirect_to projects_path
    end
  end

  def create
    @team = Team.new(team_params)
    @competition = @team.competition
    @events = current_user.competition_events_participating(@competition)
    if helpers.in_competition_window?(@team.time_zone)
      if @team.save
        handle_team_save
      else
        flash[:alert] = @team.errors.full_messages.to_sentence
        render :new
      end
    else
      flash[:alert] = "The competition has closed in event region #{@team.region.name}"
      render :new
    end
  end

  private

  def team_params
    params.require(:team).permit(:event_id, :youth_team)
  end

  def handle_team_save
    @team.assign_leader(current_user)
    @team.projects.create(team_name: "Team #{@team.id}",
                          project_name: "Project #{@team.id}",
                          user: current_user)
    flash[:notice] = 'New Team Project Created'
    redirect_to team_management_team_path(@team)
  end
end
