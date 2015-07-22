class AuthStateSerializer < ActiveModel::MongoidSerializer

  root false

  attributes :data, :links, :meta

  def data
    UserSerializer.new object[:user]
  end

  def meta
    { providers: object[:providers] }
  end

  def links
    []
  end


end
