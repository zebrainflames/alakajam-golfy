# frozen-string-literal: true

require_relative 'scene'
require_relative 'palettes'
require_relative 'physics'

SHEET_PATH = 'sprites/jam_assets/spritesheet_revamped.png'

PLANET_SMALL_ROCK = {
  path: 'sprites/jam_assets/planet_b_64.png',
  w: 64,
  h: 64,
  anchor_x: 0.5,
  anchor_y: 0.5
}.freeze

PLANET_MED_ROCK = {
  path: 'sprites/jam_assets/planet_b_128.png',
  w: 128,
  h: 128,
  anchor_x: 0.5,
  anchor_y: 0.5
}.freeze

PLANET_BIG_ROCK = {
  path: 'sprites/jam_assets/planet_b_192.png',
  w: 128,
  h: 128,
  anchor_x: 0.5,
  anchor_y: 0.5
}.freeze

BALL_SPRITE = {
  path: SHEET_PATH,
  w: 16,
  h: 16,
  tile_x: 16,
  tile_y: 0,
  tile_w: 16,
  tile_h: 16,
  anchor_x: 0.5,
  anchor_y: 0.5
}.freeze

FLAG_SPRITE = {
  path: SHEET_PATH,
  w: 16,
  h: 16,
  tile_x: 0,
  tile_y: 0,
  tile_w: 16,
  tile_h: 16,
  anchor_x: 0.5,
  anchor_y: 0.5
}.freeze

# PlanetsScene is a test scene for implementing and testing the physics simulation of the main game mechanics
# It'll be used to test mechanics and maybe to create and save levels.
class PlanetsScene < Scene
  attr_accessor :planets, :golf_ball

  def initialize(args)
    super

    reset_planets(args)
  end

  def update(_args)
    
    physics_update(@planets, @golf_ball)
  end

  def render(args)
    args.outputs.background_color = BACKGROUND_COLOR
    args.outputs.labels << [args.grid.w / 2.0, 700, 'Physics testing', 5, 1, 200, 200, 200]

    args.outputs.labels << [20.from_left, 20.from_top, "Ball: #{@golf_ball.swing_state.to_s.capitalize}", 5, 4, 200,
                            200, 200]

    args.outputs.sprites << @planets.map { |planet| planet.merge(PLANET_MED_ROCK) }

    args.outputs.sprites << @golf_ball.merge(BALL_SPRITE)
  end

  def reset_planets(args)
    @planets = []
    @planets << { x: args.grid.w / 2.0, y: args.grid.h / 2.0, mass: 120_000.0, radius: 64.0, type: :rock }

    @golf_ball = { x: args.grid.w / 2.0 + 100.0, y: args.grid.h / 2.0 + 100.0, vx: 0.0, vy: 0.0, radius: 11.0,
                   mass: 1.0, swing_state: :waiting_for_swing }
  end
end

PLANETS_SCENE = PlanetsScene.new($gtk.args)
