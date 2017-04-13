require_relative '../lib/discourse_segment/common'

module Jobs
  class SegmentAfterCreateUser < Jobs::Base
    def execute(args)
      segment = DiscourseSegment::Common.connect
      user = User.find_by(id: args[:user_id])
      user_field = UserField.find_by(name: "Organization")
      org_type = user.user_fields[user_field.id.to_s]
      segment.identify(
        user_id: user.id,
        traits: {
          name: user.name,
          username: user.username,
          email: user.email,
          org_type: org_type,
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