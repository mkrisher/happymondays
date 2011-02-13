begin
  require 'active_support/all'
rescue LoadError
  puts 'The HappyMondays gem requires ActiveSupport:  gem install activesupport'
end

module HappyMondays
  attr_accessor :week_start_day, :week_length

  def self.included(base)
    base.class_eval do

      alias_method :orig_wday, :wday
      def wday
        day = self.week_start_day || 'monday'
        result = case day.downcase
          when 'sunday'     then (self.orig_wday + 1) % 7
          when 'monday'     then (self.orig_wday) % 7
          when 'tuesday'    then (self.orig_wday - 1) % 7
          when 'wednesday'  then (self.orig_wday - 2) % 7
          when 'thursday'   then (self.orig_wday - 3) % 7
          when 'friday'     then (self.orig_wday - 4) % 7
          when 'saturday'   then (self.orig_wday - 5) % 7
          else (self.orig_wday) % 7
        end
      end

      alias_method :orig_next_week, :next_week
      def next_week()
        result = self.beginning_of_week + 7
        self.acts_like?(:time) ? result.change(:hour => 0) : result
      end

      alias_method :orig_end_of_week, :end_of_week
      def end_of_week
        self.week_length = 7 if !self.week_length.nil? && self.week_length > 7
        length = self.week_length || 7
        self.beginning_of_week + (length.days - 1.day)
      end
    end
  end
end

Date.send :include, HappyMondays

__END__

# EXAMPLE USAGE:
#
# creates date object using any day of the week,
# sets the start of the work week,
# gets the beginning of the week,
# gets the end of the week,
# gets the start of next week
#
d = Date.new(2011, 2, 8)                            # => Tue, 08 Feb 2011
d.instance_start_day = 'sunday'                     # use Sunday as the start day vs. default Monday
puts d.beginning_of_week.strftime('%a %m/%d/%Y')    # => Sun, 06 Feb 2011
puts d.end_of_week.strftime('%a %m/%d/%Y')          # => Sat, 12 Feb 2011
puts d.next_week.strftime('%a %m/%d/%Y')            # => Sun, 13 Feb 2011

# creates the date object using any day of the week
# sets the work week length in number of days
# gets the end of the week
#
d = Date.new(2011,2,7)                              # => Mon, 07 Feb 2011
d.instance_week_length = 5                          # => sets the length in num of days
puts d.end_of_week.strftime('%a %m/%d/%Y')          # => Fri, 11 Feb 2011

