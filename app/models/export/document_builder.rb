class Export::DocumentBuilder

  def initialize(set, spec)
    @set = set
    @spec = spec
  end

  def self.normalize_annotation(workflow_task, annotation)
    # puts "incoming ann: #{annotation.inspect}"
    if Project.current.export_document_specs
      # field = Project.current.export_document_specs.first.spec_fields.select { |f| f.name === workflow_task.export_name }.first
      field = Project.current.export_document_specs.first.field_by_name workflow_task.export_name
      # puts "field: .. #{field.inspect}"
      annotation = annotation['value'] if ! annotation['value'].nil?
      annotation = apply_format annotation, field.format, field.format_options
      # puts "  .. becomes: #{annotation.inspect}"
    end
    # annotation.map { |k, v|value_for_assertion
    annotation
  end

  def export_document
    doc = Export::Document.create name: @spec.name, final_subject_set: @set, spec: @spec
    @spec.spec_fields.each do |field_spec|
      fields = fields_for_field_spec(field_spec)
      doc.export_fields += fields if ! fields.blank?
    end
    if doc.export_fields.size < 3
      puts "Insufficient fields found in final-subject-set #{@set.id}: #{@set.subjects.first.location['standard']}"
      nil

    else
      doc
    end
  end

  def fields_for_field_spec(spec, base_assertion=nil)
    if ! spec.repeats
      best = best_for_field_spec(spec, base_assertion)
      [best] if ! best.nil?
    else
      all_for_field_spec(spec, base_assertion)
    end
  end

  def best_for_field_spec(spec, base_assertion=nil)
    all = all_for_field_spec(spec, base_assertion)
    all.first if ! all.nil?
  end

  def all_for_field_spec(spec, base_assertion=nil)
    assertions = assertions_for_field_spec(spec, base_assertion).sort_by { |a| - a.confidence }
    # puts "[Nothing found for #{spec.name}...]" if assertions.blank?
    return nil if assertions.blank?

    fields = assertions.map do |assertion|
      if ! spec.sub_fields.empty?
        # puts "parsing out #{spec.name}...."
        field = Export::DocumentField.new name: spec.name
        spec.sub_fields.each do |field_spec|
          # puts "  parsing out #{field_spec.name}...."
          fields = fields_for_field_spec field_spec, assertion
          field.sub_fields += fields if ! fields.blank?
        end
        field

      else
        clean_val = value_for_assertion assertion, spec.format, spec.format_options
        Export::DocumentField.new name: spec.name, value: clean_val, original_value: assertion.data, assertion_ids: [assertion.id]
      end
    end

    fields.uniq do |field|
      field.data
    end
  end

  def value_for_assertion(assertion, format=nil, format_options)
    v = assertion.data
    v = v["value"] if ! v["value"].nil?
    v = self.class.apply_format(v, format, format_options) if ! format.nil?
    v
  end

  def assertions_for_field_spec(spec, base_assertion=nil)
    # @doc["subjects"].first["assertions"].select { |a| a["name"] == name }
    # TODO add assertion.subject_id so that we can do this:
    subjects = base_assertion.nil? ? @set.subjects : [base_assertion.final_subject]
    # in the meantime we'll just do this:
    # subjects = @set.subjects
    subjects.map do |subject|
      assertions = subject.assertions
      # puts "selecting within region: #{base_assertion.region}" if ! base_assertion.nil?
      assertions = assertions.select { |assertion| assertion.region == base_assertion.region } if ! base_assertion.nil?
      assertions = assertions.select { |a| a.name == (spec.select.nil? ? spec.name : spec.select ) }
      assertions
    end.flatten
  end

  def self.apply_format(value, format, options=nil)
    # puts "apply format: #{format} to #{value.inspect}"
    case format
    when 'date'
      parse_date(value, options)
    when 'address'
      parse_address(value)
    when 'monetary'
      parse_monetary(value)
    when 'dimensions'
      parse_dimensions(value)
    when 'numeric'
      parse_numeric value
    else
      # puts "it's a hash? #{format.inspect}"
      if value.is_a?(Hash) && format.is_a?(Hash)
        # puts "it's a hash: #{format.inspect}"
        ret = {}
        value.keys.each do |k|
          ret[k] = apply_format(value[k], format[k], options)
        end
        ret
      else
        value
      end
    end
  end

  def self.parse_numeric(value)
    return nil if ! value.match /\d/
    v = value.gsub(/,|\$|\.(-|\d{2}$)?/, '').to_i
    v
  end

  # Pull arbitrary number of English system dimensions from string
  def self.parse_dimensions(value)
    dims = []
    value.split(/x/).each do |v|
      v.strip!
      fract = 0
      # If there's a fraction...
      fract_reg = / (\d+)\/(\d+)$/
      if (m = v.match(fract_reg))
        fract = m[1].to_f / m[2].to_f
        v.sub! fract_reg, ''
      end
      # If inches given as [FEET].[INCHES] or [FEET] [INCHES]" ..
      inches_reg = /(\.(\d+)| (\d+)")$/
      if (m = v.match(inches_reg))
        # This means previous fract was inches: (e.g. 1/2 inch)
        fract /= 12
        # puts "summing fact: #{fract} + (#{m[2].to_f / 12})"
        fract += m[2].to_f / 12
        v.sub! inches_reg, ''
      end
      dims << v.to_f + fract
    end
    dims
  end

  def self.parse_monetary(value)
    return nil if ! value.match /\d/
    v = value.gsub(/,|\$|\.(-|\d{2}$)?/, '').to_f
    v
  end

  def self.parse_date(value, options)
    ret = nil
    begin
      ret = Date.parse(value)
    rescue ArgumentError
      puts "invalid date: #{value}"
    end

    # Override default year expansion if a target range is configured and computed date is outside range:
    # e.g. if options["range"] == [1850,1950], `16 should default to 1916, not 2016
    # Known issue: range should be a 100 yr span (or smaller), because otherwise century may be ambiguous
    if ! ret.nil? && ! options.nil? && options["range"] && ret.year > options["range"].last
      range = options["range"]
      # Get two digit year:
      partial_year = ret.year % 100
      # Round-down range to decades (e.g. [1800,1900])
      decades = range.map { |r| r - (r % 100) }
      # See which of the (presumably 2) decades places the partial_year within range:
      corrected_year = partial_year + decades.first > range.first ? decades.first + partial_year : decades.last + partial_year
      # Rebuild date using corrected_year:
      ret = Date.new corrected_year, ret.month, ret.day
    end

    ret
  end

  def self.parse_address(value)
    value = value.dup
    value.gsub! /^no\.? /i, ''
    value
  end


end
