require_relative '../lib/discourse_segment/common'

module Jobs
  class SegmentUserBadgeGranted < Jobs::Base
    def execute(args)
      segment = DiscourseSegment::Common.connect
      badge = Badge.find_by(id: args[:badge_id])
      segment.track(
        user_id: args[:user_id],
        event: 'Badge Granted',
        properties: {
          name: badge.name
        }
      )
      segment.flush
    end
  end
end