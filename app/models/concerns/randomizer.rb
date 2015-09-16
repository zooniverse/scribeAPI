module Randomizer
  extend ActiveSupport::Concern

  module ClassMethods
    # Returns a random selection of docs
    #
    # @param [Int] :limit => the number of documents to find, :selector => randomly select documents matching this criteria
    # @param [Hash] :selector => A hash of where queries to apply

    # @return [Array] the randomly selected documents
    def random(*args)
      opts = { :limit => 1 }.update(args.extract_options!)
      opts[:selector] ||= args.first || {}

      number = rand
      dir = [:asc,:desc].sample

      # First, try to find :limit docs that are >= num
      criteria = where(opts[:selector]).asc(:random_no).limit(opts[:limit])
      result = criteria.where( :random_no.gte => number)

      # Not enough found?
      if result.count < opts[:limit]
        # Try finding :limit docs that are <= num
        criteria = where(opts[:selector]).desc(:random_no).limit(opts[:limit])
        result = criteria.where( :random_no.lte => number)

        # Still not enough found? The collection count must be < :limit, so return all
        if result.count < opts[:limit]
          result = where(opts[:selector]).order_by([:random_no, dir])
        end
      end

      result
    end

    def random_order
      order [ :random_no, [:asc,:desc].shuffle.first ]
    end
  end

  def save
    self.random_no = rand
    super
  end

  def create
    r = self
    r.random_no = rand
    r.save
    r
  end
end
