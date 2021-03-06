require_relative '../lib/discourse_segment/common'

module Jobs
  class SegmentPageviews < Jobs::Base
    def execute(args)
      segment = DiscourseSegment::Common.connect
      controller_name = args[:controller]
      action_name = args[:action]
      path = URI.parse(args[:original_url]).path
      if path == "/"
        segment.page(
          user_id: args[:user_id],
          name: "Home",
          properties: {
            url: path,
            tab: action_name
          },
          context: {
            ip: args[:ip],
            userAgent: args[:user_agent]
          }
        )
      elsif path =~ /^\/latest/
        page_name = "Latest Page"
        segment.page(
          user_id: args[:user_id],
          name: "Latest",
          properties: {
            url: path,
            tab: action_name
          },
          context: {
            ip: args[:ip],
            userAgent: args[:user_agent]
          }
        )
      elsif path =~ /^\/top/
        segment.page(
          user_id: args[:user_id],
          name: "Top",
          properties: {
            url: path,
            tab: action_name
          },
          context: {
            ip: args[:ip],
            userAgent: args[:user_agent]
          }
        )
      elsif path =~ /^\/unread/
        segment.page(
          user_id: args[:user_id],
          name: "Unread",
          properties: {
            url: path,
            tab: action_name
          },
          context: {
            ip: args[:ip],
            userAgent: args[:user_agent]
          }
        )
      elsif path =~ /^\/new/
        segment.page(
          user_id: args[:user_id],
          name: "New",
          properties: {
            url: path,
            tab: action_name
          },
          context: {
            ip: args[:ip],
            userAgent: args[:user_agent]
          }
        )
      elsif path =~ /^\/categories/
        segment.page(
          user_id: args[:user_id],
          name: "Categories",
          properties: {
            url: path
          },
          context: {
            ip: args[:ip],
            userAgent: args[:user_agent]
          }
        )
      elsif path =~ /^\/c/ && controller_name == "list"
        category = Category.find_by(slug: args[:params][:category])
        if category.parent_category_id
          segment.page(
            user_id: args[:user_id],
            name: "Subcategory",
            properties: {
              url: path,
              category_id: category.parent_category_id,
              category_name: Category.find_by(id: category.parent_category_id).name,
              subcategory_id: category.id,
              subcategory_name: category.name,
              tab: action_name
            },
            context: {
              ip: args[:ip],
              userAgent: args[:user_agent]
            }
          )
        else
          segment.page(
            user_id: args[:user_id],
            name: "Category",
            properties: {
              url: path,
              category_id: category.id,
              category_name: category.name,
              tab: action_name
            },
            context: {
              ip: args[:ip],
              userAgent: args[:user_agent]
            }
          )
        end
      elsif path =~ /^\/t/ && controller_name == "topics" && action_name == "show"
        if args[:params][:topic_id]
          topic_id = args[:params][:topic_id]
        else
          topic_id = args[:params][:id]
        end
        topic = Topic.find_by(id: topic_id)
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
          tag_name = Tag.find_by(id: tag.tag_id).name
          tags = "#{tags}#{tag_name}|"
        end
        tags = tags[0...-1]
        segment.page(
          user_id: args[:user_id],
          name: "Topic",
          properties: {
            slug: topic.slug,
            title: topic.title,
            url: topic.url,
            category_id: category,
            category_name: category_name,
            subcategory_id: subcategory,
            subcategory_name: subcategory_name,
            userTags: tags,
            postedBy: topic.user_id
          },
          context: {
            ip: args[:ip],
            userAgent: args[:user_agent]
          }
        )
      elsif path =~ /^\/u/ && path =~ /\/preferences$/ && controller_name == "users" && action_name == "show"
        segment.page(
          user_id: args[:user_id],
          name: "Preferences",
          properties: {
            url: path,
            tab: action_name
          },
          context: {
            ip: args[:ip],
            userAgent: args[:user_agent]
          }
        )
      end
      segment.flush
    end
  end
end