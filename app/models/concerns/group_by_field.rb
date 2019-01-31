module GroupByField
  extend ActiveSupport::Concern

  module ClassMethods

    # Returns hash mapping distinct values for given field to matching count:
    def group_by_field(field, match={})
      puts "group #{collection.inspect} by #{field}"
      agg = []
      agg << {"$match" => match } if match
      agg << {"$group" => { "_id" => "$#{field.to_s}", count: {"$sum" =>  1} }}
      collection.aggregate(agg).inject({}) do |h, p|
        h[p["_id"]] = p["count"]
        h
      end
    end

  end
end
