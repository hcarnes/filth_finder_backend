class EstablishmentsController < ApplicationController
  def near_me
    establishments = Establishment.order(["establishments.location <-> ?::geography", "SRID=4326;POINT(#{params[:lng].to_f} #{params[:lat].to_f})"]).limit(50)

    render json: establishments
  end
end