require_relative '../lib/discourse_segment/common'

module Jobs
  class SegmentAfterCreatePost < Jobs::Base
    def execute(args)
      segment = DiscourseSegment::Common.connect
      post = Post.find_by(id: args[:post_id])
      if post.topic.category.parent_category_id.nil?
        category = post.topic.category.id
        category_name = post.topic.category.name
        subcategory = nil
        subcategory_name = nil
      else
        category = post.topic.category.parent_category_id
        category_name = Category.find_by(id: category).name
        subcategory = post.topic.category.id
        subcategory_name = post.topic.category.name
      end
      tags = ""
      post.topic.topic_tags.each do |tag|
        tag_name = Tag.find_by(id: tag.tag_id).name
        tags = "#{tags}#{tag_name}|"
      end
      tags = tags[0...-1]
      segment.track(
        user_id: args[:user_id],
        event: 'Post Created',
        properties: {
          slug: post.topic.slug,
          title: post.topic.title,
          url: post.topic.url,
          category_id: category,
          category_name: category_name,
          subcategory_id: subcategory,
          subcategory_name: subcategory_name,
          userTags: tags
        }
      )
      segment.flush
    end
  end
end