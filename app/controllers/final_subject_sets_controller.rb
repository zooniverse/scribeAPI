class FinalSubjectSetsController < FinalDataController 
  respond_to :json

  def show
    @set = FinalSubjectSet.find params[:id]
    respond_with FinalSubjectSetSerializer.new @set
  end

  def index
    per_page              = get_int :per_page, 20, (0..50)
    page                  = get_int :page, 1

    field                 = params[:field]
    keyword               = params[:keyword]

    
    @sets = Project.current.final_subject_sets.page(page).per(per_page)
    if ! field.blank? && (field_spec = FinalSubjectSet.export_spec_fields.select { |f| f.name == field }.first)
      
      match_exact = ['numeric','monetary','date'].include? field_spec.format
      if field_spec && field_spec.format
        split = "(-|to)"
        split = " #{split} " if field_spec.format == 'date'
        if keyword.match /\w+ ?#{split} ?\w+/i
          values = keyword.split(/#{split}/i)
          values = [values.first, values.last]
          values = parse_range values, field_spec.format

          @sets = @sets.by_export_field_range(field, values)

        # specially handle searching by year:
        elsif field_spec.format == 'date' && keyword.match(/^\d+$/)
          values = parse_range [keyword,keyword], field_spec.format
          @sets = @sets.by_export_field_range(field, values)

        # search by exact val:
        else
          value = parse_keyword keyword, field_spec.format
          @sets = value.blank? ? [] : @sets.by_export_field(field, value, match_exact)
        end
      else
        value = parse_keyword keyword, field_spec.format
        @sets = value.blank? ? [] : @sets.by_export_field(field, value, match_exact)
      end

    else
      @sets = @sets.where({"$text" => {"$search" => keyword} } ) if keyword
    end

    respond_with GenericResultSerializer.new(@sets)
  end

  def parse_range(values, format)
    parsed = values.map { |v| Export::DocumentBuilder.apply_format v, format }
    if format == 'date'
      parsed[0] = Export::DocumentBuilder.apply_format("#{values.first}-01-01",format) if parsed.first.nil?
      parsed[1] = Export::DocumentBuilder.apply_format("#{values.last}-12-31",format) if parsed.last.nil?
    end
    parsed
  end

  def parse_keyword(value, format)
    parsed = Export::DocumentBuilder.apply_format value, format
    parsed
  end
end
