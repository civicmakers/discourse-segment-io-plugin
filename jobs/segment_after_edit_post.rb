require_relative '../lib/discourse_segment/common'

module Jobs
  class SegmentAfterEditPost < Jobs::Base
    def execute(args)
      segment = DiscourseSegment::Common.connect
      post = Post.find_by(id: args[:post_id])
      if post.topic.category.parent_category_id.nil?
        category = post.topic.category.id
        subcategory = nil
      else
        category = post.topic.category.parent_category_id
        subcategory = post.topic.category.id
      end
      tags = ""
      post.topic.topic_tags.each do |tag|
        tags = "#{tags}#{tag.tag_id}|"
      end
      tags = tags[0...-1]
      segment.track(
        user_id: args[:user_id],
        event: 'Post Edited',
        properties: {
          slug: post.topic.slug,
          title: post.topic.title,
          url: post.topic.url,
          category: category,
          subcategory: subcategory,
          userTags: tags,
          postedBy: args[:user_id]
        }
      )
      segment.flush
    end
  end
end