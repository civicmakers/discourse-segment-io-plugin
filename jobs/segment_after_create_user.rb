require_relative '../lib/discourse_segment/common'

module Jobs
  class SegmentAfterCreateUser < Jobs::Base
    def execute(args)
      segment = DiscourseSegment::Common.connect
      user = User.find_by(id: args[:user_id])
      traits = {
        name: user.name,
        username: user.username,
        email: user.email,
        created_at: user.created_at
      }
      user.user_fields.each do |cf|
        user_field = UserField.find_by(id: cf[0].to_i)
        trait_name = user_field.name.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
        traits["#{trait_name}"] = cf[1]
      end
      segment.identify(
        user_id: user.id,
        traits: traits,
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