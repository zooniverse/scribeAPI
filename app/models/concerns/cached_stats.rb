module CachedStats
  extend ActiveSupport::Concern

  included do
    field :stats, type: Hash, default: {}
    # PB: Detaching this callback because it really complicates performance 
    #   measures and punishes random users needlessly. Going forward let's
    #   require code to explicitly call `project.check_and_update_stats`
    # set_callback :find, :after, :check_and_update_stats
    class_attribute :interval
  end

  def check_and_update_stats
    update_attributes stats: self.calc_stats if  stats_need_update?
  end

  def stats_need_update?
    Time.new - updated_at > ( self.interval || 10)
  end

  module ClassMethods
    def update_interval(interval)
      self.interval = interval
    end
  end
end
