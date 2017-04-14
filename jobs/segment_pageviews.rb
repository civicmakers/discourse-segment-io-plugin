require_relative '../lib/discourse_segment/common'

module Jobs
  class SegmentPageviews < Jobs::Base
    def execute(args)
      segment = DiscourseSegment::Common.connect
      controller_name = args[:controller]
      action_name = args[:action]
      path = URI.parse(args[:original_url]).path
      if path == "/" && controller_name == "list"
        segment.page(
          user_id: args[:user_id],
          name: "Viewed Home Page",
          properties: {
            url: path,
            tab: action_name
          },
          context: {
            ip: args[:ip],
            userAgent: args[:user_agent]
          }
        )
      elsif path =~ /^\/latest/ && controller_name == "list" && action_name == "latest"
        page_name = "Viewed Latest Page"
        segment.page(
          user_id: args[:user_id],
          name: "Viewed Latest Page",
          properties: {
            url: path,
            tab: action_name
          },
          context: {
            ip: args[:ip],
            userAgent: args[:user_agent]
          }
        )
      elsif path =~ /^\/top/ && controller_name == "list" && action_name == "top"
        segment.page(
          user_id: args[:user_id],
          name: "Viewed Top Page",
          properties: {
            url: path,
            tab: action_name
          },
          context: {
            ip: args[:ip],
            userAgent: args[:user_agent]
          }
        )
      elsif path =~ /^\/unread/ && controller_name == "list" && action_name == "unread"
        segment.page(
          user_id: args[:user_id],
          name: "Viewed Unread Page",
          properties: {
            url: path,
            tab: action_name
          },
          context: {
            ip: args[:ip],
            userAgent: args[:user_agent]
          }
        )
      elsif path =~ /^\/new/ && controller_name == "list" && action_name == "new"
        segment.page(
          user_id: args[:user_id],
          name: "Viewed New Page",
          properties: {
            url: path,
            tab: action_name
          },
          context: {
            ip: args[:ip],
            userAgent: args[:user_agent]
          }
        )
      elsif path =~ /^\/categories/ && controller_name == "categories" && action_name == "index"
        segment.page(
          user_id: args[:user_id],
          name: "Viewed Categories Index",
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
            name: "Viewed Subcategory Page",
            properties: {
              url: path,
              category: category.parent_category_id,
              subcategory: category.id,
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
            name: "Viewed Category Page",
            properties: {
              url: path,
              category: category.id,
              tab: action_name
            },
            context: {
              ip: args[:ip],
              userAgent: args[:user_agent]
            }
          )
        end
      elsif path =~ /^\/t/ && controller_name == "topics" && action_name == "show"
        topic = Topic.find_by(id: args[:params][:id])
        if topic.category.parent_category_id.nil?
          category = topic.category.id
          subcategory = nil
        else
          category = topic.category.parent_category_id
          subcategory = topic.category.id
        end
        tags = ""
        topic.topic_tags.each do |tag|
          tags = "#{tags}#{tag.tag_id}|"
        end
        tags = tags[0...-1]
        segment.page(
          user_id: args[:user_id],
          name: "Viewed Topic Page",
          properties: {
            slug: topic.slug,
            title: topic.title,
            url: topic.url,
            category: category,
            subcategory: subcategory,
            userTags: tags,
            postedBy: topic.user_id
          },
          context: {
            ip: args[:ip],
            userAgent: args[:user_agent]
          }
        )
      elsif path =~ /^\/u/ && path =~ /\/preferences$/
        segment.page(
          user_id: args[:user_id],
          name: "Viewed User Preferences",
          properties: {
            url: path,
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
          name: "#{controller_name}##{action_name}",
          properties: {
            url: args[:original_url]
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