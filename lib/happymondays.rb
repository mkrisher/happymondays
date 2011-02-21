begin
  require 'active_support/all'
rescue LoadError
  puts 'The HappyMondays gem requires ActiveSupport:  gem install activesupport'
end

module HappyMondays

  def self.included(base)
    base.class_eval do

      def week_start_day=(val)
        @start = val
      end

      def week_start_day
        @start
      end

      def week_length=(val)
        @length = val
      end

      def week_length
        @length || 7
      end

      alias_method :orig_wday, :wday
      def wday
        self.set_from_thread if @start.nil? && self.thread?
        day = self.week_start_day || Date::DAYNAMES[self.orig_wday]
        result = case day.downcase
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

      alias_method :orig_beginning_of_week, :beginning_of_week
      def beginning_of_week
        set_default_week_start
        days_to_wday = self.orig_wday - self.wday
        res = self.dup
        res = res - days_to_wday.days
        res.week_start_day = self.week_start_day # set the week_start_day so wday returns the correct 'day name' in the new date
        res.acts_like?(:time) ? res.midnight : res
      end

      alias_method :orig_next_week, :next_week
      def next_week()
        result = self.beginning_of_week + 7
        self.acts_like?(:time) ? result.change(:hour => 0) : result
      end

      alias_method :orig_end_of_week, :end_of_week
      def end_of_week
        set_default_week_start
        length = self.week_length
        length = 7 if length > 7
        # if in a Thread this can't return self because wday is wrong
        if thread?
          res = Date.new(self.year, self.month, ( (self.day + length - 1) - (self.orig_wday - self.wday) ) )
          res.week_start_day = Date::DAYNAMES[self.wday + length - 1] # set the week_start_day so wday returns the correct 'day name' in the new date
          res
        else
          self.beginning_of_week + (length.days - 1.days)
        end
      end

      def set_from_thread
        self.week_start_day = Thread.current["week_start_day"]
        self.week_length    = Thread.current["week_length"]
      end

      def thread?
        !Thread.current['week_start_day'].nil?
      end

      def set_default_week_start
        self.week_start_day = 'monday' if @start.nil? && !self.thread?
      end
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
d = Date.new(2011, 2, 8)                            # => Tue, 08 Feb 2011
d.week_start_day = 'sunday'                         # use Sunday as the start day vs. default Monday
puts d.beginning_of_week.strftime('%a %m/%d/%Y')    # => Sun, 06 Feb 2011
puts d.end_of_week.strftime('%a %m/%d/%Y')          # => Sat, 12 Feb 2011
puts d.next_week.strftime('%a %m/%d/%Y')            # => Sun, 13 Feb 2011

# creates the date object using any day of the week
# sets the work week length in number of days
# gets the end of the week
#
d = Date.new(2011,2,7)                              # => Mon, 07 Feb 2011
d.week_length = 5                                   # => sets the length in num of days
puts d.end_of_week.strftime('%a %m/%d/%Y')          # => Fri, 11 Feb 2011

# or if you prefer to use Threads
d = Date.new(2011, 2, 8)
Thread.current['week_start_day'] = 'sunday'
puts d.beginning_of_week.strftime('%a %m/%d/%Y')    # => Sun, 06 Feb 2011
puts d.end_of_week.strftime('%a %m/%d/%Y')          # => Sat, 12 Feb 2011
puts d.next_week.strftime('%a %m/%d/%Y')            # => Sun, 13 Feb 2011

