require_relative '../lib/discourse_segment/common'

module Jobs
  class SegmentAfterCreateUser < Jobs::Base
    def execute(args)
      segment = DiscourseSegment::Common.connect
      user = User.find_by(id: args[:user_id])
      segment.identify(
        user_id: user.id,
        traits: {
          name: user.name,
          username: user.username,
          email: user.email,
          org_type: "placeholder",
          created_at: user.created_at
        },
        context: {
          ip: user.ip_address
        }
      )
      segment.track(
        user_id: user.id,
        event: 'Signed Up'
      )
      segment.flush
    end
  end
end