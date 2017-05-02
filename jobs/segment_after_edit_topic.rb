require_relative '../lib/discourse_segment/common'

module Jobs
  class SegmentAfterEditTopic < Jobs::Base
    def execute(args)
      segment = DiscourseSegment::Common.connect
      topic = Post.find_by(id: args[:post_id]).topic
      if topic.category.parent_category_id.nil?
        category = topic.category.id
        category_name = topic.category.name
        subcategory = nil
        subcategory_name = nil
      else
        category = topic.category.parent_category_id
        category_name = Category.find_by(id: category).name
        subcategory = topic.category.id
        subcategory_name = topic.category.name
      end
      tags = ""
      topic.topic_tags.each do |tag|
        tags = "#{tags}#{tag.tag_id}|"
      end
      tags = tags[0...-1]
      segment.track(
        user_id: args[:user_id],
        event: 'Topic Edited',
        properties: {
          slug: topic.slug,
          title: topic.title,
          url: topic.url,
          category_id: category,
          category_name: category_name,
          subcategory_id: subcategory,
          subcategory_name: subcategory_name,
          userTags: tags,
          postedBy: args[:user_id]
        }
      )
      segment.flush
    end
  end
end