require 'test_helper'

class ScorecardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users :one
    @project = Project.first
    @header= Header.third
    Competition.first.update(
      peoples_choice_start: Time.now.yesterday,
      peoples_choice_end: Time.now.tomorrow
    )
  end

  test 'should get new' do
    get new_project_scorecard_path(@project.identifier)
    assert_response :success
  end

  test 'should get edit' do
    get edit_project_scorecard_path(@project.identifier, @header)
    assert_response :success
  end
end
