{
  :'en-AU' => {
    :date => {
      :formats => {
        :long_ordinal => lambda { |date| "#{date.day.ordinalize} %B, %Y" }
      },
      :day_names => Date::DAYNAMES,
      :abbr_day_names => Date::ABBR_DAYNAMES,
      :month_names => Date::MONTHNAMES,
      :abbr_month_names => Date::ABBR_MONTHNAMES,
      :order => [:year, :month, :day]
    },
    :time => {
      :formats => {
        :long_ordinal => lambda { |time| "#{time.day.ordinalize} %B, %Y %H:%M" }
      },
      :time_with_zone => {
        :formats => {
          :default => lambda { |time| "%Y-%m-%d %H:%M:%S #{time.formatted_offset(false, 'UTC')}" }
        }
      }
    }
  }
}
