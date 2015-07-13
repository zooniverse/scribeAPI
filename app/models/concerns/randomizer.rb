module Randomizer
  extend ActiveSupport::Concern

  module ClassMethods
    # Finds sequential random documents.
    #
    # @param [Hash] :limit => the number of documents to find, :selector => randomly select documents matching this criteria
    # @return [Array] the randomly selected documents
    def random(*args)
      # puts "args are, ",args
      opts = { :limit => 1 }.update(args.extract_options!)
      opts[:selector] ||= args.first || {}

      # puts "opts are ", opts
      # puts opts[:selector]
      orders = [
        [:random_no.asc, :random_no.gte],
        [:random_no.desc, :random_no.lt]
      ].shuffle

      number = rand
      # puts "random selection is #{number}"
      criteria = where(opts[:selector]).asc(:random_no).limit(opts[:limit])
      result = criteria.where( :random_no.gte => number).all

      criteria = where(opts[:selector]).desc(:random_no).limit(opts[:limit])
      criteria = criteria.limit(opts[:limit] - result.length)

      # PB: No, we're not doing this. It converts the result to an array, preventing further chaining:
      # result += criteria.where(:random_no.lt => number).all if result.length < opts[:limit]

      result
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
