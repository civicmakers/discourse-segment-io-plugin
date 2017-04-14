DiscourseSegment::Engine.routes.draw do
  post "/track-share" => "segment#track_share"
end