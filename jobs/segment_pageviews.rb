require_relative '../lib/discourse_segment/common'

module Jobs
  class SegmentPageviews < Jobs::Base
    def execute(args)
      segment = DiscourseSegment::Common.connect
      controller_name = args[:controller]
      action_name = args[:action]
      segment.page(
        user_id: args[:user_id],
        name: "#{controller_name}##{action_name}",
        properties: {
          url: args[:original_url]
        },
        context: {
          ip: args[:ip],
          userAgent: args[:user_agent]
        }
      )
      segment.flush
    end
  end
end