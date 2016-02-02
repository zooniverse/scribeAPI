class FinalSubject
  include Mongoid::Document

  field :type,                       type: String
  field :location,                   type: Hash
  field :status,                     type: String
  field :width,                      type: Integer
  field :height,                     type: Integer
  field :meta_data,                  type: Hash
  field :data,                       type: Hash
  field :classifications_breakdown,  type: Hash
  field :flags,                      type: Hash

  belongs_to :subject
  embedded_in :final_subject_set, inverse_of: :subjects
  embeds_many :assertions, class_name: 'FinalSubjectAssertion'

  def fulltext_terms
    assertions.select { |assertion| ! assertion.data.blank? && assertion.created_in_workflow != 'mark' }.map { |assertion| assertion.data.values }.select { |v| ! v.empty? }
  end

  def fulltext_terms_by_field
    assertions.select { |assertion| ! assertion.data.blank? && assertion.created_in_workflow != 'mark' }.inject({}) do |h, a| 
      field_name = a.name.blank? ? '_' : a.name
      h[field_name] = [] if h[field_name].nil?
      h[field_name] += a.data.values.select { |v| ! v.empty? }
      h
    end
  end

  def self.create_from_subject(subject)
    inst = self.new subject: subject
    [:type, :location, :status, :width, :height, :meta_data].each do |p|
      inst.send("#{p}=", subject.send(p))
    end

    inst.build_assertions!
    # inst.build_classifications_breakdown!
    # inst.build_data!

    inst
  end

  def build_data!
    distinct = assertions.inject({}) do |h, assertion|
      if assertion.created_in_workflow != 'mark'
        h[assertion.task_key] = [] if h[assertion.task_key].nil?
        data = assertion.data
        data = data["values"].first if ! data["values"].nil?
        data = data["value"] if data["value"]
        stmt = {value: data, label: assertion.instructions['transcribe']}
        has_data = ! data.blank?
        has_data &= ! data.values.select { |v| ! v.blank? }.empty? if data.is_a? Hash
        h[assertion.task_key] << stmt if has_data && ! h[assertion.task_key].include?(stmt)
      end
      h
    end
    self.data = distinct
  end

  def build_assertions!
    assertions.destroy_all

    flattened_subjects(subject.child_subjects).each do |s|
      assertions << FinalSubjectAssertion.create_from_subject(s[:subject], s[:parents])
    end

    self
  end

  def build_classifications_breakdown!
    all_classifications = []
    @all_subjects.each do |s|
      all_classifications += s.classifications
    end
    self.classifications_breakdown = all_classifications.inject({}) { |h, c| h[c.task_key] ||= 0; h[c.task_key] += 1; h }
    self.classifications_breakdown[:total] = subject.classifications.count
  end

  def flags
    {
      complete: flagged_for_retirement,
      bad: {
        votes_in_favor: subject.flagged_bad_count || 0
      }
    }
  end

  def flagged_for_retirement
    votes = subject.number_of_completion_assessments
    h = {
      votes_in_favor: subject.retire_count || 0,
      total_votes: votes,
    }
    h[:percentage_in_favor] = subject.retire_count / votes.to_f if ! subject.retire_count.nil? && votes > 0
    h
  end

  def flattened_subjects(subjects, parents = [])
    @all_subjects ||= []
    @all_subjects += subjects

    ret = []
    subjects.each do |s|
      next if ! s.parent_classifications.empty? && s.parent_classifications.limit(1).first.task_key == 'completion_assessment_task'

      if s.child_subjects.size > 0
        ret += flattened_subjects(s.child_subjects, parents + [s])

      else
        # ret << FinalSubjectAssertionSerializer.new(subject: s, parents: parents)
        ret << {subject: s, parents: parents} if s.status != 'bad'
      end
    end
    ret
  end
end
