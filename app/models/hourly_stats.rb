# An internal model used to hold hourly statistic information for various reasons.
# Such as message per hour or actions per hour.
class HourlyStats
  attr_accessor :hour, :value
end
