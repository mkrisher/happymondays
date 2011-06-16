begin
  require 'active_support/all'
rescue LoadError
  puts 'The HappyMondays gem requires ActiveSupport:  gem install activesupport'
end

module HappyMondays

  def self.included(base)
    base.class_eval do

      def adjusted_wday
        day     = self.week_end_day.nil? ? self.week_start_day : self.week_end_day
        result  = case day.downcase
          when 'sunday'     then 0
          when 'monday'     then 1
          when 'tuesday'    then 2
          when 'wednesday'  then 3
          when 'thursday'   then 4
          when 'friday'     then 5
          when 'saturday'   then 6
          else 1
        end
      end

      def adjusted_beginning_of_week
        clear_end_day
        days_to_wday        = self.wday - self.adjusted_wday
        res                 = self.dup
        res                 = res - days_to_wday.days
        res.week_start_day  = self.week_start_day
        res.acts_like?(:time) ? res.midnight : res
      end

      def adjusted_end_of_week
        length              = self.week_length
        res                 = Date.new(self.year, self.month, (self.day + length - 1) - (self.wday - self.adjusted_wday))
        calc                = res.adjusted_wday - 1 if length == 7
        calc                = res.adjusted_wday + (length - 1) if length != 7
        res.week_end_day    = Date::DAYNAMES[calc]
        res.acts_like?(:time) ? res.midnight : res
      end

      def adjusted_next_week
        clear_end_day
        res                 = self.adjusted_beginning_of_week + 7.days
        res.week_start_day  = self.week_start_day
        res.acts_like?(:time) ? res.change(:hour => 0) : res
      end

      def clear_end_day
        self.week_end_day    = nil
      end
      
    end    

    base.extend         Methods
    base.send :include, Methods

  end
  
  module Methods
    def week_start_day=(val)
      Thread.current[:week_start_day] = val
    end

    def week_start_day
      Thread.current[:week_start_day] || 'monday'
    end

    def week_end_day=(val)
      Thread.current[:week_end_day] = val
    end

    def week_end_day
      Thread.current[:week_end_day]
    end

    def week_length=(val)
      val = 7 if val > 7
      Thread.current[:week_length] = val
    end

    def week_length
      Thread.current[:week_length] || 7
    end
  end
  
end

Date.send :include, HappyMondays

__END__

# EXAMPLE USAGE:
#
require 'rubygems'
require 'happymondays'

# creates date object using any day of the week,
# sets the start of the work week,
# gets the beginning of the week,
# gets the end of the week,
# gets the start of next week
#
Date.week_start_day = 'sunday'                      # use Sunday as the start day vs. default Monday
d = Date.new(2011, 2, 8)                            # => Tue, 08 Feb 2011
puts d.adjusted_beginning_of_week.strftime('%a %m/%d/%Y')    # => Sun, 06 Feb 2011
puts d.adjusted_end_of_week.strftime('%a %m/%d/%Y')          # => Sat, 12 Feb 2011
puts d.adjusted_next_week.strftime('%a %m/%d/%Y')            # => Sun, 13 Feb 2011

# creates the date object using any day of the week
# sets the work week length in number of days
# gets the end of the week
#
d = Date.new(2011,2,7)                              # => Mon, 07 Feb 2011
d.week_length = 5                                   # => sets the length in num of days
puts d.adjusted_end_of_week.strftime('%a %m/%d/%Y') # => Fri, 11 Feb 2011

# or if you prefer to use Threads
d = Date.new(2011, 2, 8)
Thread.current['week_start_day'] = 'sunday'
puts d.adjusted_beginning_of_week.strftime('%a %m/%d/%Y')    # => Sun, 06 Feb 2011
puts d.adjusted_end_of_week.strftime('%a %m/%d/%Y')          # => Sat, 12 Feb 2011
puts d.adjusted_next_week.strftime('%a %m/%d/%Y')            # => Sun, 13 Feb 2011

