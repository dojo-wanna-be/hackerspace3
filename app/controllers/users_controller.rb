class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
    @competition = Competition.current

    @assignments = @user.assignments
    @assignment_titles = @assignments.pluck(:title)

    @team_id_assignments = {}
    @assignments.each do |assignment|
      next unless assignment.assignable_type == 'Team'

      @team_id_assignments[assignment.assignable_id] = assignment
    end

    @id_regions = Region.id_regions(Region.all)

    @event_assignment = @user.event_assignment
    @registrations = Registration.where(assignment: @assignments)

    @sponsor_contact_assignments = @assignments.where(title: SPONSOR_CONTACT)
    @id_sponsors = Sponsor.id_sponsors(@sponsor_contact_assignments.pluck(:assignable_id))

    @favourite_teams = @event_assignment.teams.published.preload(:event, :current_project)

    @id_events = Event.id_events(@registrations.pluck(:event_id))

    @joined_teams = @user.joined_teams.preload(:event, :current_project)
    @invited_teams = @user.invited_teams.preload(:event, :current_project)

    @public_winning_entries = @user.public_winning_entries?
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    @account_registration = @user.registering_account?
    if params[:user].nil?
      redirect_to root_path
    else
      handle_update_user
    end
  end

  private

  def user_params
    params.require(:user).permit(:full_name, :preferred_name, :preferred_img,
                                 :tshirt_size, :twitter, :phone_number, :mailing_list,
                                 :challenge_sponsor_contact_place, :challenge_sponsor_contact_enter,
                                 :my_project_sponsor_contact, :me_govhack_contact, :dietary_requirements,
                                 :organisation_name, :how_did_you_hear, :govhack_img,
                                 :accepted_terms_and_conditions, :bsb, :acc_number, :acc_name, :branch_name)
  end

  def handle_update_user
    @user.update(user_params) unless params.nil?
    if @user.save
      account_update_successfully
    else
      render 'edit'
    end
  end

  def account_update_successfully
    if params[:user][:accepted_terms_and_conditions]
      handle_complete_registration
    elsif @account_registration
      handle_end_of_registration
    elsif params[:user][:govhack_img].present?
      handle_profile_img
    elsif params[:banking].present?
      handle_bank_update
    else
      handle_personal_details
    end
  end

  def handle_complete_registration
    flash[:notice] = 'Welcome! Please complete your registration.'
    redirect_to complete_registration_path
  end

  def handle_end_of_registration
    current_user.update(how_did_you_hear: NO_RESPONSE) if @user.how_did_you_hear.empty?
    flash[:notice] = 'Your account has been created.'
    redirect_to manage_account_path
  end

  def handle_profile_img
    flash[:notice] = 'GovHack Profile Uploaded'
    render :edit, profile_pic: true
  end

  def handle_bank_update
    BankMailer.notify_finance(@user).deliver_later
    flash[:notice] = 'Your banking details have been updated.'
    redirect_to manage_account_path
  end

  def handle_personal_details
    flash[:notice] = 'Your personal details have been updated.'
    redirect_to manage_account_path
  end
end
