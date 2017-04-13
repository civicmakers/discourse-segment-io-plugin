module DiscourseSegment
  class Engine < ::Rails::Engine
    isolate_namespace DiscourseSegment

    config.after_initialize do

    require_dependency 'application_controller'
    class ::ApplicationController
      before_filter :emit_segment_user_tracker
      def emit_segment_user_tracker
        if current_user && !segment_common_controller_actions?
          # Analytics.page(
          #   user_id: current_user.id,
          #   name: "#{controller_name}##{action_name}",
          #   properties: {
          #     url: request.original_url
          #   },
          #   context: {
          #     ip: request.ip,
          #     userAgent: request.user_agent
          #   }
          # )
        end
      end

      def segment_common_controller_actions?
        controller_name == 'stylesheets' || controller_name == 'user_avatars' || (controller_name == 'about' && action_name == 'live_post_counts')
      end
    end

    end

  end
end

DiscourseEvent.on(:post_created) do |post, _, user|
  Jobs.enqueue(:segment_after_create_post, {post_id: post.id, user_id: user.id })
end

DiscourseEvent.on(:topic_created) do |topic, _, user|
  Jobs.enqueue(:segment_after_create_topic, {topic_id: topic.id, user_id: user.id })
end

DiscourseEvent.on(:user_created) do |user|
  Jobs.enqueue(:segment_after_create_user, {user_id: user.id })
end

DiscourseEvent.on(:post_edited) do |post, topic_changed|
  Jobs.enqueue(:segment_after_edit_post, {post_id: post.id, user_id: current_user.id })

  if topic_changed
    Jobs.enqueue(:segment_after_edit_topic, {post_id: post.id, user_id: current_user.id }) 
  end   
end

DiscourseEvent.on(:user_seen) do |user|
  Jobs.enqueue(:segment_user_seen, {user_id: user.id })
end
