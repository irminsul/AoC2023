#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'parslet'

CubeSet = Data.define(:red, :green, :blue) do
  # @param other [CubeSet]
  # @return CubeSet
  def +(other)
    self.class.new(*deconstruct.zip(other.deconstruct).map(&:sum))
  end

  # @param other [CubeSet]
  # @return Boolean
  def >=(other)
    deconstruct.zip(other.deconstruct).all? { |a, b| a >= b }
  end

  # @return Integer
  def power
    deconstruct.reduce(&:*)
  end
end

Game = Data.define(:id, :draws) do
  # @param cube_set [CubeSet]
  # @return Boolean
  def possible?(cube_set)
    draws.all? { |d| cube_set >= d }
  end

  # @return CubeSet
  def min_cubes
    CubeSet.new(*draws.map(&:deconstruct).transpose.map(&:max))
  end
end

# Let's use a proper parser instead of regular expressions and `String#split` 🙂
class InputParser < Parslet::Parser
  rule(:space) { match('\s').repeat(1) }
  rule(:space?) { space.maybe }
  rule(:comma?) { str(',').maybe >> space? }
  rule(:colon) { str(':') >> space? }
  rule(:semicolon?) { str(';').maybe >> space? }

  rule(:integer) { match['0-9'].repeat(1).as(:int) >> space? }
  rule(:color) { (str('red') | str('green') | str('blue')).as(:sym) }

  rule(:cube_set) { integer.as(:count) >> color.as(:color) >> comma? }
  rule(:draw) { cube_set.repeat(1, 3).as(:cube_set) >> semicolon? }
  rule(:game) { str('Game') >> space >> integer.as(:id) >> colon >> draw.repeat(1).as(:draws) }
  rule(:games) { game.repeat }

  root :games
end

class InputTransform < Parslet::Transform
  rule(int: simple(:x)) { Integer(x) }
  rule(sym: simple(:x)) { x.to_sym }
  rule(count: simple(:count), color: simple(:color)) { CubeSet.new(red: 0, green: 0, blue: 0, **{ color => count }) }
  rule(cube_set: sequence(:x)) { x.reduce(&:+) }
  rule(id: simple(:id), draws: sequence(:draws)) { Game.new(id:, draws:) }
end

input = File.read(File.join(File.dirname(__FILE__), 'input'))
games = InputTransform.new.apply(InputParser.new.parse(input))

# Part 1
bag = CubeSet.new(red: 12, green: 13, blue: 14)
pp games.select { |g| g.possible?(bag) }.sum(&:id)

# Part 2
pp games.map { |g| g.min_cubes.power }.sum
