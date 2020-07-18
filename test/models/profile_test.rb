require 'test_helper'

class ProfileTest < ActiveSupport::TestCase
  setup do
    @profile = profiles(:one)
    @user = users(:one)
  end

  test 'associations' do
    assert @profile.user == @user
  end

  test 'validations' do
    assert_not Profile.create(identifier: @profile.identifier).save
  end

  test 'enums' do
    assert Profile.first_peoples.is_a? Hash
    assert Profile.disabilities.is_a? Hash
    assert Profile.educations.is_a? Hash
    assert Profile.employments.is_a? Hash
    assert Profile.ages.is_a? Hash
  end

  test 'update_identifier callback' do
    @profile.touch
    @profile.reload
    assert @profile.identifier == 'user_number_one'

    @user.update preferred_name: 'example name'
    @profile.reload
    assert @profile.identifier == 'example_name'
  end
end
