class PagesController < ApplicationController

  layout 'landing_page'
  skip_authorization_check

  def home
    @current_nav_identifier = :home
  end

  #Function to track subcriptions
  #should be changed once proper subscription system has been completed
  def newsletter
    if params.has_key?(:type)
      ahoy.track "Clicked pricing link", type: params[:type]
    end
  end

  #Function to track time spent in a page
  def track_time

    if params.has_key?(:time) && params.has_key?(:location)
      unless (params[:location].include? "metrics")
        time = params[:time]
        ahoy.track "Time Spent", time: time
      end
      head 200, content_type: "text/html"
    else
      head 500
    end
  end

end
