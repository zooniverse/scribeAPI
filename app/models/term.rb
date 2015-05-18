class Term
  include Mongoid::Document

  field    :term,                                            type: String
  field    :count,                                           type: Integer, default: 0
  field    :annotation_key,                                  type: String 

  belongs_to :workflow

  index({ term: 1 }, { unique: true, name: "term_index" })

  def self.autocomplete(workflow_id, annotation_key, q)
    reg = /#{Regexp.escape(q)}/
    where(workflow_id: workflow_id, annotation_key: annotation_key, term: reg).map { |t| t.term }
  end

  def self.index_term!(workflow_id, annotation_key, term)
    find_or_create_by(term: term, workflow_id: workflow_id, annotation_key: annotation_key).inc count: 1
  end
end
