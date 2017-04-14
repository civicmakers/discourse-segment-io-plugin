require_relative '../lib/discourse_segment/common'

module Jobs
  class SegmentAfterDestroyBookmark < Jobs::Base
    def execute(args)
      segment = DiscourseSegment::Common.connect
      post = Post.find_by(id: args[:post_id])
      segment.track(
        user_id: args[:user_id],
        event: 'Post Bookmark Removed',
        properties: {
          slug: post.topic.slug,
          title: post.topic.title,
          url: post.topic.url
        }
      )
      segment.flush
    end
  end
end