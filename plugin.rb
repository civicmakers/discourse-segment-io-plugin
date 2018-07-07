# name: Segment.io
# about: Import your Discourse data to your Segment.io warehouse
# version: 0.1
# authors: Kyle Welsby <kyle@mekyle.com>, Joe Buhlig <hello@joebuhlig.com>
# url: https://github.com/civicmakers/discourse-segment-io-plugin

gem 'commander', '4.4.0' # , require: false # for analytics-ruby
gem 'analytics-ruby', '2.2.2', require: false # 'segment/analytics'

after_initialize do

  load File.expand_path('../jobs/segment_after_create_bookmark.rb', __FILE__)
  load File.expand_path('../jobs/segment_after_create_post.rb', __FILE__)
  load File.expand_path('../jobs/segment_after_create_topic.rb', __FILE__)
  load File.expand_path('../jobs/segment_after_create_user.rb', __FILE__)
  load File.expand_path('../jobs/segment_after_destroy_bookmark.rb', __FILE__)
  load File.expand_path('../jobs/segment_after_edit_post.rb', __FILE__)
  load File.expand_path('../jobs/segment_after_edit_topic.rb', __FILE__)
  load File.expand_path('../jobs/segment_after_like_post.rb', __FILE__)
  load File.expand_path('../jobs/segment_after_unlike_post.rb', __FILE__)
  load File.expand_path('../jobs/segment_pageviews.rb', __FILE__)
  load File.expand_path('../jobs/segment_share_dialog.rb', __FILE__)
  load File.expand_path('../jobs/segment_user_badge_granted.rb', __FILE__)
  load File.expand_path('../jobs/segment_user_badge_removed.rb', __FILE__)
  load File.expand_path('../jobs/segment_user_logged_out.rb', __FILE__)
  load File.expand_path('../jobs/segment_user_seen.rb', __FILE__)

  require_dependency 'application_controller'
  class ::ApplicationController
    before_action :emit_segment_user_tracker
    def emit_segment_user_tracker
      if current_user && !segment_common_controller_actions?
        Jobs.enqueue(:segment_pageviews, {
          user_id: current_user.id, 
          controller: controller_name, 
          action: action_name, 
          original_url: request.referrer, 
          ip: request.ip, 
          user_agent: request.user_agent,
          params: params
          })
      end
    end

    def segment_common_controller_actions?
      controller_name == 'stylesheets' || controller_name == 'user_avatars' || (controller_name == 'about' && action_name == 'live_post_counts') || action_name == 'timings' || action_name == 'destroy'
    end
  end

  require_dependency 'user_action'
  class ::UserAction
    after_create :segment_after_create_user_action
    after_destroy :segment_after_destroy_user_action
    def segment_after_create_user_action
      if self.action_type == 1
        Jobs.enqueue(:segment_after_like_post, {post_id: self.target_post.id, user_id: self.user.id })
      elsif self.action_type == 3
        Jobs.enqueue(:segment_after_create_bookmark, {post_id: self.target_post.id, user_id: self.user.id })
      end
    end

    def segment_after_destroy_user_action
      if self.action_type == 1
        Jobs.enqueue(:segment_after_unlike_post, {post_id: self.target_post.id, user_id: self.user.id })
      elsif self.action_type == 3
        Jobs.enqueue(:segment_after_destroy_bookmark, {post_id: self.target_post.id, user_id: self.user.id })
      end
    end
  end

  load File.expand_path('../lib/discourse_segment/engine.rb', __FILE__)

end