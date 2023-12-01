#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'

# Read input from the file
input = File.read(File.join(File.dirname(__FILE__), 'input'))

# Part 1
lines = input.lines(chomp: true)

calibration_values = lines.map do |line|
  digits = line.gsub(/\D/, '')
  "#{digits[0]}#{digits[-1]}".to_i
end

pp calibration_values.sum

# Part 2
replacements = {
  'one' => 1,
  'two' => 2,
  'three' => 3,
  'four' => 4,
  'five' => 5,
  'six' => 6,
  'seven' => 7,
  'eight' => 8,
  'nine' => 9
}

re = /(?=(\d|#{replacements.keys.join('|')}))/

calibration_values = lines.map do |line|
  digits = line.scan(re).map { |d| replacements[d[0]] || d[0] }
  "#{digits[0]}#{digits[-1]}".to_i
end

pp calibration_values.sum
