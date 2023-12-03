#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'English'

input = File.read(File.join(File.dirname(__FILE__), 'input'))

Position = Data.define(:x, :y)
Part = Data.define(:type, :part_numbers) do
  GEAR_TYPE = '*'

  # @return [Boolean]
  def gear?
    type == GEAR_TYPE && part_numbers.length == 2
  end

  # @return [Integer, nil]
  def gear_ratio
    part_numbers.reduce(&:*) if gear?
  end
end

class Schematic
  # @param data [String]
  def initialize(data)
    self.data = data.lines(chomp: true)
    self.height = self.data.length
    self.width = self.data[0].length
    parse
  end

  # @return [Array<Part>]
  attr_reader :parts

  private

  # @return [Array<String>]
  attr_accessor :data

  # @return [Integer]
  attr_accessor :width, :height

  def parse
    # Step 1: Identify the locations of all parts
    part_map = Enumerator.product(0...width, 0...height).each.with_object({}) do |(x, y), hash|
      hash[Position[x, y]] = Part[data[y][x], []] if data[y][x].match?(/[^\d.]/)
    end

    @parts = part_map.values

    # Step 2: Assign part numbers to the parts
    data.each_with_index do |line, y|
      line.scan(/\d+/) do |part_number|
        # Start and end offset of the part number within the line
        x0 = $LAST_MATCH_INFO.begin(0) - 1
        x1 = $LAST_MATCH_INFO.end(0)

        # List of all schematic positions around the part number
        neighbors = Enumerator.product(x0..x1, y - 1..y + 1).map { |pos| Position[*pos] }

        # Append the part number to all parts around the part number
        (part_map.keys & neighbors).each do |part_position|
          part_map[part_position].part_numbers << part_number.to_i
        end
      end
    end
  end
end

schematic = Schematic.new(input)

# Part 1
# Note: This exploits a special property of the input - each number belongs at most to one part.
pp schematic.parts.flat_map(&:part_numbers).sum

# Part 2
pp schematic.parts.filter_map(&:gear_ratio).sum
