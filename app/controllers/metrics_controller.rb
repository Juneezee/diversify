class MetricsController < ApplicationController

  layout 'metrics_page'

  def index
    @total_visits = Ahoy::Visit.all
    if @total_visits.present?
      @total_visits_count = @total_visits.length
    else
      @total_visits_count = 0
    end

    @today_visits = Ahoy::Visit.where(started_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).length
    unless @today_visits.present?
      @today_visits = 0
    end

    @subscriptions = Ahoy::Event.where(name: "Clicked pricing link")
  end

  def traffic
    @device_count = Ahoy::Visit.all.group(:device_type).count
    @browser_count = Ahoy::Visit.all.group(:browser).count
    @country_count = Ahoy::Visit.all.group(:country).count

    @data = Ahoy::Visit.all
  end

  def update_graph_time
    if params.has_key?(:graph_name)
      @id = "#graph-div"
      # decide on layout
      if params[:graph_name].include? "by Date"
        @layout = "metrics/_linegraph.haml"
      elsif params[:graph_name].include? "per Page"
        @layout = "metrics/_barchart.haml"
      else
        @layout = "metrics/_piechart.haml"
      end

      #decide on Data and Grouping
      if params[:graph_name].include? "Subscription"
        @data = Ahoy::Event.where(name: "Clicked pricing link")
        @group = "properties -> 'type'"
        @time = "time"
      elsif params[:graph_name].include? "Visits"
        @data = Ahoy::Event.where(name: "Ran action")
        @group = "properties -> 'action'"
      elsif params[:graph_name].include? "Average Time Spent"
        @data = Ahoy::Event.where(name: "Time Spent")
        @group = "properties -> 'location'"
        @average = "cast(properties ->> 'time' as float)"
      elsif params[:graph_name].include? "Referrers"
        @data = Ahoy::Visit.all
        @group = "referrer"
        @time = "started_at"
      end

      # set time constraint to graphs if exist
      if params[:graph_name].include? "Referrers"
        if @data.present? && params[:time].length() == 2
          @data = @data.where(started_at: DateTime.parse(params[:time][0])..DateTime.parse(params[:time][1]) + 1.days)
        elsif @data.present? && params[:time].length() == 1
          @data = @data.where(started_at: DateTime.parse(params[:time]))
        end
      else
        if @data.present? && params[:time].length() == 2
          @data = @data.where(time: DateTime.parse(params[:time][0])..DateTime.parse(params[:time][1]) + 1.days)
        elsif @data.present? && params[:time].length() == 1
          @data = @data.where(time: DateTime.parse(params[:time]))
        end
      end

      #Check if theres is still valid data, else return "No Data"
      if @data.present?
        return_partial(@id, @layout, {data: @data, group_by: @group, time: @time, average: @average})
      else
        return_partial(nil, nil, {})
      end
    else
      head 500
    end
  end

  # def return_partial(time_data, id, layout, group, time)
  def return_partial(id, layout, locals)
    print("HERE LIES THE GREAT LOCALS #{locals}")
    if locals[:data].present?
      response = generate_json_response(id, layout, locals)
      respond_to do |format|
        format.json { render :json => response, :status => 200 }
      end
    else
      respond_to do |format|
        format.json { render :json => {:title => "#graph-div", :html => "<p>No Data</p>"},
                             :status => 200 }
      end
    end
  end

  def generate_json_response(title, template, locals)
    json = {:title => title,
            # Renders the ERB partial to a string
            :html => render_to_string(
                :template => template, # The ERB partial
                :formats => :html, # The string format
                :layout => false, # Skip the application layout
                :locals => locals) # Pass the model object with errors
    }
    return json
  end
end
