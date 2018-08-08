require 'test_helper'

class EventTest < ActiveSupport::TestCase
  setup do
    @event = Event.first
    @region = Region.second
    @competition = Competition.first
    @assignment = Assignment.third
    @registration = Registration.find(1)
    @user = User.first
    @team = Team.first
  end

  test 'event associations' do
    assert(@event.region == @region)
    assert(@event.competition == @competition)
    assert(@event.assignments.include?(@assignment))
    assert(@event.registrations.include?(@registration))
    assert(@event.registration_assignments.include?(@registration.assignment))
    assert(@event.teams.include?(@team))
  end

  test 'event validations' do
    # No name
    assert_not(Event.create(name: nil).persisted?)
    # Duplicate Name
    assert_not(Event.create(name: @event.name).persisted?)
  end

  test 'attending method' do
    assert(@event.attending?(@user.event_assignment))
  end
end
