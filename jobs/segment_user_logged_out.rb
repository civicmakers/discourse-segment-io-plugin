require_relative '../lib/discourse_segment/common'

module Jobs
  class SegmentUserLoggedOut < Jobs::Base
    def execute(args)
      segment = DiscourseSegment::Common.connect
      user = User.find_by(id: args[:user_id])
      segment.track(
        user_id: user.id,
        event: 'User Logged Out'
      )
      segment.flush
    end
  end
end