require_relative '../lib/discourse_segment/common'

module Jobs
  class SegmentAfterEditTopic < Jobs::Base
    def execute(args)
      segment = DiscourseSegment::Common.connect
      topic = Post.find_by(id: args[:post_id]).topic
      segment.track(
        user_id: args[:user_id],
        event: 'Topic Edited',
        properties: {
          slug: topic.slug,
          title: topic.title,
          url: topic.url
        }
      )
      segment.flush
    end
  end
end