#!/usr/bin/env ruby

begin
  require 'rubygems'
rescue LoadError
  puts 'rubygems could not be loaded'
end

begin
  require 'redgreen'
rescue
end

require 'test/unit'

require File.expand_path(File.dirname(__FILE__) + "/../lib/happymondays")
