# frozen_string_literal: true

# Date scoping module
# see https://api.rubyonrails.org/classes/ActiveSupport/Concern.html
module DateScope
  extend ActiveSupport::Concern

  included do
    scope :on_date, lambda { |query,time|
      where(query+' BETWEEN ? AND ?',
            DateTime.parse(time),
            DateTime.parse(time) + 1.days)
    }

    scope :between_date, lambda { |query, time1, time2|
      where(query+' BETWEEN ? AND ?',
            DateTime.parse(time1),
            DateTime.parse(time2) + 1.days)
    }
  end
end
