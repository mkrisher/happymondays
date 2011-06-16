require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class HappyMondaysTest < Test::Unit::TestCase
  def setup
    Thread.current['week_start_day'] = nil
    Thread.current['week_length'] = nil
    @my_date = Date.new(2011, 2, 8)
  end

  def test_week_start_day
    @my_date.clear_end_day
    Date.week_start_day = 'sunday'
    assert_equal  0, @my_date.adjusted_wday
    Date.week_start_day = 'monday'
    assert_equal  1, @my_date.adjusted_wday
    Date.week_start_day = 'tuesday'
    assert_equal  2, @my_date.adjusted_wday
    Date.week_start_day = 'wednesday'
    assert_equal  3, @my_date.adjusted_wday
    Date.week_start_day = 'thursday'
    assert_equal  4, @my_date.adjusted_wday
    Date.week_start_day = 'friday'
    assert_equal  5, @my_date.adjusted_wday
    Date.week_start_day = 'saturday'
    assert_equal  6, @my_date.adjusted_wday
  end

  def test_week_length
    @my_date.week_length = 3
    assert_equal  3, @my_date.week_length
  end

  def test_default_adjusted_beginning_of_week
    assert_equal  'monday', @my_date.week_start_day
    assert_equal  'Mon 02/07/2011', @my_date.adjusted_beginning_of_week.strftime('%a %m/%d/%Y')
  end
  
  def test_nondefault_adjusted_beginning_of_week
    @my_date = Date.new(2011, 2, 8)
    @my_date.week_start_day = 'sunday'
    assert_equal  0, @my_date.adjusted_wday
    assert_equal  'Sun 02/06/2011', @my_date.adjusted_beginning_of_week.strftime('%a %m/%d/%Y')

    @my_new_date = Date.new(2011, 2, 8)
    @my_new_date.week_start_day = 'Tuesday' # non downcase
    assert_match  'Tuesday', @my_new_date.week_start_day
    assert_equal  'Tue 02/08/2011', @my_new_date.adjusted_beginning_of_week.strftime('%a %m/%d/%Y')
  end

  def test_default_adjusted_end_of_week
    assert_equal  'monday', @my_date.week_start_day
    assert_equal  'Sun 02/13/2011', @my_date.adjusted_end_of_week.strftime('%a %m/%d/%Y')
  end
  
  def test_nondefault_adjusted_end_of_week
    @my_date.week_start_day = 'tuesday'
    assert_equal  'Mon 02/14/2011', @my_date.adjusted_end_of_week.strftime('%a %m/%d/%Y')
  end

  def test_default_adjusted_next_week
    assert_equal  'monday', @my_date.week_start_day
    assert_equal  'Mon 02/14/2011', @my_date.adjusted_next_week.strftime('%a %m/%d/%Y')
  end

  def test_nondefault_adjusted_next_week
    @my_date.week_start_day = 'tuesday'
    assert_equal  'Tue 02/15/2011', @my_date.adjusted_next_week.strftime('%a %m/%d/%Y')
  end

  def test_default_week_length
    assert_equal  'Mon 02/07/2011', @my_date.adjusted_beginning_of_week.strftime('%a %m/%d/%Y')
    assert_equal  'Sun 02/13/2011', @my_date.adjusted_end_of_week.strftime('%a %m/%d/%Y')
  end

  def test_nondefault_week_length
    @my_date.week_length = 5
    @my_date.week_start_day = 'monday'
    assert_equal  'monday', @my_date.week_start_day
    assert_equal  'Mon 02/07/2011', @my_date.adjusted_beginning_of_week.strftime('%a %m/%d/%Y')
    assert_equal  'Fri 02/11/2011', @my_date.adjusted_end_of_week.strftime('%a %m/%d/%Y')
    assert_equal  'Mon 02/07/2011', @my_date.adjusted_beginning_of_week.strftime('%a %m/%d/%Y')

    # week starts on monday 2/7
    @my_date.week_length = 14 # week length can't be greater than 7
    assert_equal  'Mon 02/07/2011', @my_date.adjusted_beginning_of_week.strftime('%a %m/%d/%Y')
    assert_equal  'Sun 02/13/2011', @my_date.adjusted_end_of_week.strftime('%a %m/%d/%Y')
  end

  def test_multithreading
    t1 = Thread.new do
      @first_date = Date.new(2011, 2, 8)
      @first_date.week_start_day = 'sunday'
      assert_equal  'sunday', @first_date.week_start_day
      assert_equal  'Sun 02/06/2011', @first_date.adjusted_beginning_of_week.strftime('%a %m/%d/%Y')
    end
    t2 = Thread.new do
      @second_date = Date.new(2011, 2, 8)
      @second_date.week_start_day = 'monday'
      assert_equal  'monday', @second_date.week_start_day
      assert_equal  'Mon 02/07/2011', @second_date.adjusted_beginning_of_week.strftime('%a %m/%d/%Y')
    end
    t1.join
    t2.join
    t3 = Thread.new do
      @first_date = Date.new(2011, 2, 8)
      @first_date.week_start_day = 'sunday'
      assert_equal  'sunday', @first_date.week_start_day
      assert_equal  'Sun 02/06/2011', @first_date.adjusted_beginning_of_week.strftime('%a %m/%d/%Y')

      t4 = Thread.new do
        @second_date = Date.new(2011, 2, 8)
        @second_date.week_start_day = 'monday'
        assert_equal  'monday', @second_date.week_start_day
        assert_equal  'Mon 02/07/2011', @second_date.adjusted_beginning_of_week.strftime('%a %m/%d/%Y')
      end
    end
  end

  def test_using_thread_outside_of_self
    @thread_date = Date.new(2011, 2, 8) # => 'tuesday'
    Thread.current['week_start_day']  = 'sunday'
    Thread.current['week_length']     = 4
    assert_equal  'Sun 02/06/2011',   @thread_date.adjusted_beginning_of_week.strftime('%a %m/%d/%Y')
    assert_equal  'Wed 02/09/2011',   @thread_date.adjusted_end_of_week.strftime('%a %m/%d/%Y')
    assert_equal  'Sun 02/13/2011',   @thread_date.adjusted_next_week.strftime('%a %m/%d/%Y')
  end
end
