# frozen_string_literal: true

require_relative 'scene' # Make sure to require the Scene class

class GameplayScene < Scene # Inherit from Scene
  def initialize(_args)
    super
    @state[:counter] = 66
  end

  def update(args) # Implement update method, args is passed in
    # puts "counter is #{@state[:counter]}"
    @state[:counter] = 0 if @state[:counter] > args.grid.h
    @state[:counter] += 1
  end

  def render(args) # Implement render method, args is passed in
    args.outputs.background_color = [20, 25, 20]
    args.outputs.labels << [20.from_left, @state[:counter], 'Gravity Golf Gameplay!', 5, 4, 244, 255, 244]
  end
end

GAMEPLAY_SCENE = GameplayScene.new($args) # Instantiate the scene object

