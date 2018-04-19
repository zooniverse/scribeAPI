atom_feed do |feed|

  feed.title("#{Project.current.title} Data Exports")
  feed.updated(@exports[0].created_at) if @exports.length > 0

  @exports.each do |export|
    feed.entry(export) do |entry|
      entry.title("#{export.updated_at.strftime('%c')}: #{export.num_final_subject_sets} subjects")
    end
  end
end
