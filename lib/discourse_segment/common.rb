require 'segment/analytics'

module DiscourseSegment
  class Common

    def self.connect
      if !SiteSetting.segment_io_key.empty?
        return Segment::Analytics.new(
          write_key: SiteSetting.segment_io_key,
          on_error: proc { |_status, msg| print msg }
        )
      else
        raise NotImplementedError
      end
    end

  end
end