class FavouritesController < ApplicationController
  respond_to :json
  # before_filter :authenticate_user!


  def index
  	respond_with current_user.favourites
  end

  def create
    resond_with status:404, message: 'you must provide a subject id' unless params[:subject_id]
    subject    = Subject.find(params[:subject_id])
    favourite  = current_user.favourites.create(subject: subject)
    if favourite
      respond_with favourite
    else
      respond_with status:404
    end
  end

  def destroy

    favourite = current_user.favourites.find_by(id: params[:id]) || current_user.favourites.find_by(subject_id: params[:subject_id])

    if favourite
      subject = favourite.subject
      favourite.destroy
      respond_with subject, status: 200
    else
      respond_with status: 404, message:'you must provide a subject id or a favourite id'
    end
  end

end
