# frozen_string_literal: true

# Controller for metrics
class MetricsController < ApplicationController
  skip_after_action :track_action
  skip_before_action :track_ahoy_visit

  layout 'metrics_page'

  def index
    @static_data = [
      Ahoy::Visit.count,
      Ahoy::Visit.where(
        started_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day
      )
                 .size,
      NewsletterSubscription.count
    ]
  end

  def traffic
    @static_data = [
      Ahoy::Visit.all.group(:device_type).count,
      Ahoy::Visit.all.group(:browser).count,
      Ahoy::Visit.all.group(:country).count
    ]
  end

  def update_graph_time
    if graph_params
      # decide on layout
      layout = helpers.decide_layout(params[:graph_name])

      # decide on Data and Grouping
      data, config = data_setter(params[:graph_name])
      # set time constraint to graphs if exist
      if (params[:graph_name].include? 'by Newsletter') && !params[:time].empty?
        date1, date2 = params[:time]
        data =
          data.select do |v|
            if !date2.nil?
              DateTime.parse(date1) < v[:created_at] &&
                v[:created_at] < DateTime.parse(date2) + 1.days
            else
              DateTime.parse(date1) < v[:created_at] &&
                v[:created_at] < DateTime.parse(date1) + 1.days
            end
          end
      elsif !params[:time].empty?
        data = helpers.time_constraint(config[:time], data)
      end

      if params[:graph_name].include? 'by Newsletter'
        data = [
          {
            title: 'Unsubscription',
            data:
              data.collect do |i|
                [
                  "#{i['title']} #{i['created_at'].utc.strftime('%Y-%m-%d')}",
                  i['feedback_count']
                ]
              end
          }
        ]
      elsif params[:graph_name].include? 'Reason'
        data[0][:data] = NewsletterFeedback.count_reason(data[0][:data])
      end

      # Check if there is still valid data, else return "No Data"
      if helpers.there_data?(data)
        config[:data] = data
        return_partial('#graph-div', layout, config)
      else
        return_partial(nil, nil, {})
      end
    else
      head 500
    end
  end

  def return_partial(id, layout, locals)
    if locals[:data].present?
      render json: generate_json_response(id, layout, locals)
    else
      render json: { title: '#graph-div', html: '<p>No Data</p>' }
    end
  end

  def generate_json_response(title, template, locals)
    {
      title: title,
      html:
        render_to_string(
          # Renders the ERB partial to a string
          template: template,
          # The ERB partial
          formats: :html,
          # The string format
          layout: false,
          # Skip the application layout
          locals: locals
        )
    } # Pass the model object with errors
  end

  # set
  def data_setter(option)
    case option
    when /Reason/
      data = NewsletterFeedback.select(:reason, :created_at)
      data = [{ title: 'Reason', data: data }]
      config = { time: 'created_at', average: nil, group_by: nil }
    when /Landing Page/
      data = [
        { title: 'Sastifaction', data: LandingFeedback.select(:smiley) },
        { title: 'Channel', data: LandingFeedback.select(:channel) },
        { title: 'Recommend', data: LandingFeedback.select(:interest) }
      ]
      config = { time: 'started_at', average: nil, group_by: nil }
    when /by Newsletter/
      data =
        Newsletter.find_by_sql(
          "SELECT newsletters.title,
         newsletters.created_at, COUNT(newsletter_feedbacks)
         as feedback_count FROM newsletters JOIN newsletter_feedbacks
         ON newsletter_feedbacks.created_at BETWEEN newsletters.created_at
         AND newsletters.created_at+interval'7 days' GROUP BY newsletters.id"
        )
      config = { time: 'created_at', average: nil, group_by: nil }
    when /Newsletter/
      data = [
        { title: 'Subscription', data: NewsletterSubscription.all },
        { title: 'Unsubscription', data: NewsletterFeedback.all }
      ]
      config = { time: 'created_at', average: nil, group_by: nil }
    when /Subscription/
      data = [
        {
          title: 'Subscription',
          data: Ahoy::Event.where(name: 'Clicked pricing link')
        }
      ]
      config = { group_by: "properties -> 'type'", time: 'time', average: nil }
    when /Visits/
      data = [{ title: 'Visit', data: Ahoy::Event.where(name: 'Ran action') }]
      config = {
        group_by: "properties -> 'action'", average: nil, time: 'time'
      }
    when /Average Time Spent/
      data = [
        { title: 'Time Spent', data: Ahoy::Event.where(name: 'Time Spent') }
      ]
      config = {
        group_by: "properties -> 'pathname'",
        average: "cast(properties ->> 'time' as float)",
        time: 'time'
      }
    when /Referrers/
      data = [{ title: 'Referrers', data: Ahoy::Visit.all }]
      config = { group_by: 'referrer', time: 'started_at', average: nil }
    else
      data = []
      config = []
    end
    [data, config]
  end

  private

  def graph_params
    params.require(:metric)
  end
end
