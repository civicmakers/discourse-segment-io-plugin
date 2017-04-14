module DiscourseSegment
  class TrackingController < ApplicationController

    def track_share
      Jobs.enqueue(:segment_share_dialog, {post_id: params[:post_id], user_id: params[:user_id] })
      render json: success_json
    end

  end
end