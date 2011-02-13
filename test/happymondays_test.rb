require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class HappyMondaysTest < Test::Unit::TestCase
  def setup
    @my_date = Date.new(2011, 2, 8)
  end

  def test_default_date_beginning_of_week
    assert_nil    @my_date.week_start_day
    assert_equal  @my_date.beginning_of_week.strftime('%a %m/%d/%Y'), 'Mon 02/07/2011'
  end

  def test_nondefault_beginning_of_week
    @my_date.week_start_day = 'sunday'
    assert_match  @my_date.week_start_day, 'sunday'
    assert_equal  @my_date.beginning_of_week.strftime('%a %m/%d/%Y'), 'Sun 02/06/2011'

    @my_date.week_start_day = 'Tuesday' # non downcase
    assert_match  @my_date.week_start_day, 'Tuesday'
    assert_equal  @my_date.beginning_of_week.strftime('%a %m/%d/%Y'), 'Tue 02/08/2011'
  end

  def test_default_end_of_week
    assert_nil    @my_date.week_start_day
    assert_equal  @my_date.end_of_week.strftime('%a %m/%d/%Y'), 'Sun 02/13/2011'
  end

  def test_nondefault_end_of_week
    @my_date.week_start_day = 'tuesday'
    assert_equal  @my_date.end_of_week.strftime('%a %m/%d/%Y'), 'Mon 02/14/2011'
  end

  def test_default_next_week
    assert_nil    @my_date.week_start_day
    assert_equal  @my_date.next_week.strftime('%a %m/%d/%Y'), 'Mon 02/14/2011'
  end

  def test_nondefault_end_of_week
    @my_date.week_start_day = 'tuesday'
    assert_equal  @my_date.next_week.strftime('%a %m/%d/%Y'), 'Tue 02/15/2011'
  end

  def test_default_week_length
    assert_equal  @my_date.end_of_week.strftime('%a %m/%d/%Y'), 'Sun 02/13/2011'
    assert_equal  @my_date.next_week.strftime('%a %m/%d/%Y'), 'Mon 02/14/2011'
  end

  def test_nondefault_week_length
    @my_date.week_length = 5
    assert_equal  @my_date.end_of_week.strftime('%a %m/%d/%Y'), 'Fri 02/11/2011'
    assert_equal  @my_date.next_week.strftime('%a %m/%d/%Y'), 'Mon 02/14/2011'
  end

  def test_multithreading
    @first_date   = Date.new(2011, 2, 8)
    @second_date  = Date.new(2011, 3, 1)
    @first_date.week_start_day  = 'sunday'
    @second_date.week_start_day = 'tuesday'

    assert_equal  @first_date.beginning_of_week.strftime('%a %m/%d/%Y'), 'Sun 02/06/2011'
    assert_equal  @second_date.beginning_of_week.strftime('%a %m/%d/%Y'), 'Tue 03/01/2011'
  end
end
