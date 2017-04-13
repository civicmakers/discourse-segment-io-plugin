require_relative '../lib/discourse_segment/common'

module Jobs
  class SegmentAfterCreateTopic < Jobs::Base
    def execute(args)
      segment = DiscourseSegment::Common.connect
      topic = Topic.find_by(id: args[:topic_id])
      segment.track(
        user_id: args[:user_id],
        event: 'Topic Created',
        properties: {
          slug: topic.slug,
          title: topic.title,
          url: topic.url
        }
      )
    end
  end
end