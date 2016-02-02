class FinalDataController < ApplicationController
  before_filter :ensure_data_downloadable

  def ensure_data_downloadable
    project = Project.current
    return render text: 'Data is not yet publicly available for this Scribe project.', status: 404 if ! project.downloadable_data
  end

end
