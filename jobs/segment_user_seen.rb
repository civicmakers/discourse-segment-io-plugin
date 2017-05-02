require_relative '../lib/discourse_segment/common'

module Jobs
  class SegmentUserSeen < Jobs::Base
    def execute(args)
      segment = DiscourseSegment::Common.connect
      user = User.find_by(id: args[:user_id])
      user_custom = []
      user.user_fields.each do |cf|
        user_field = UserField.find_by(id: cf[0].to_i)
        user_custom.push("#{user_field.name}": cf[1])
      end
      segment.identify(
        user_id: user.id,
        traits: {
          name: user.name,
          username: user.username,
          email: user.email,
          user_custom: user_custom,
          created_at: user.created_at
        },
        context: {
          ip: user.ip_address
        }
      )
      segment.track(
        user_id: user.id,
        event: 'User Seen'
      )
      segment.flush
    end
  end
end