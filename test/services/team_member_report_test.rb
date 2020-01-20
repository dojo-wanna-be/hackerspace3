require 'test_helper'

class TeamMemberReportTest < ActiveSupport::TestCase
  setup do
    @competition = Competition.first
  end

  test 'to_csv' do
    TeamMemberReport.new(@competition).to_csv.class == String
  end
end
