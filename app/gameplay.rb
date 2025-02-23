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
  w: 22,
  h: 22,
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
class GameplayScene < Scene
  attr_accessor :planets, :golf_ball

  def initialize(args)
    super

    load_level()
    reset_planets(args)
  end

  def load_level
    @level_won = false
    @strokes = 0
  end

  def ball_out_of_bounds?(args)
    @golf_ball.x < 0 || @golf_ball.x > args.grid.w || @golf_ball.y < 0 || @golf_ball.y > args.grid.h
  end

  def update(args)
    if @level_won
      return
    end

    player_input(args)
    physics_update(@planets, @golf_ball) if can_update_physics?

    if ball_out_of_bounds?(args)
      # TODO: play sound cue
      # todo: display some sort of particle fx at pont of impact
      # todo: increase stroke counter
      reset_planets(args)
    end

    if ball_collides_with_flag?
      @level_won = true
    end
  end

  def render(args)
    args.outputs.background_color = BACKGROUND_COLOR
    #args.outputs.labels << [args.grid.w / 2.0, 700, 'Physics testing', 5, 1, 200, 200, 200]
    if @level_won
      args.outputs.labels << [args.grid.w / 2.0, 700, "Level complete in #{@strokes} strokes.", 5, 1, 200, 200, 200]
      args.outputs.labels << [args.grid.w / 2.0, 650, 'Press "SPACE" to load next level.', 5, 1, 200, 200, 200]
    end

    args.outputs.labels << [20.from_left, 20.from_top, "Strokes: #{@strokes}", 5, 4, 200,
                            200, 200] unless @level_won

    args.outputs.sprites << @planets.map { |planet| planet.merge(PLANET_MED_ROCK) }

    args.outputs.sprites << @golf_ball.merge(BALL_SPRITE)

    args.outputs.sprites << @flag.merge(FLAG_SPRITE)

    # draw a line from ball to mouse cursor if player is dragging
    if @golf_ball.swing_state == :swinging
      render_trajectory_projection(args)
    end
  end

  def reset_planets(args)
    @planets = []
    @planets << create_med_planet(args.grid.w / 2.0, args.grid.h / 2.0, :rock)
    @golf_ball = { x: args.grid.w / 2.0, y: args.grid.h / 2.0 + 64 + 8, vx: 0.0, vy: 0.0, av: 0.0, radius: 11.0,
                   mass: 1.0, swing_state: :waiting_for_swing }
    @ball_flying_for = 0
    @flag = { x: args.grid.w / 2.0, y: args.grid.h / 2.0 - 64 - 8, radius: 8.0, angle: 180 }
  end

  private 

  def ball_collides_with_flag?
    dx = @golf_ball.x - @flag[:x]
    dy = @golf_ball.y - @flag[:y]
    distance = Math.sqrt(dx**2 + dy**2)
    distance < @golf_ball.radius + @flag.radius
  end

  def create_med_planet(x, y, type = :rock)
    { x: x, y: y, mass: 120_000.0, radius: 64.0, type: type }
  end

  def create_small_planet(x, y, type = :rock)
    { x: x, y: y, mass: 45_000.0, radius: 32.0, type: type }
  end

  def create_big_planet(x, y, type = :rock)
    { x: x, y: y, mass: 240_000.0, radius: 96.0, type: type }
  end

  def render_trajectory_projection(args)
    projected_points = predict_trajectory(@planets, @golf_ball, args)

    projected_points.each_with_index do |point, index|
      alpha = 200 - (index * (200.0 / projected_points.length)).to_i
      size = 2

      args.outputs.sprites << {
        x: point[:x],
        y: point[:y],
        w: size,
        h: size,
        path: :pixel,
        r: 220, g: 220, b: 220,
        achor_x: 0.5,
        anchor_y: 0.5,
        a: alpha
      }
    end
  end

  def can_update_physics?
    @golf_ball.swing_state == :ready || @golf_ball.swing_state == :flying
  end

  def can_swing?
    @golf_ball.swing_state == :waiting_for_swing || @golf_ball.swing_state == :ready
  end

  def player_input(args)
    return if Kernel.tick_count <= 5 # ugly hacks to ignore clicks from resetting game
    # detect if player is dragging mouse
    if args.inputs.mouse.click && can_swing?
      puts "Drag started"
      @golf_ball.swing_state = :swinging
      @golf_ball.swing_start_x = args.inputs.mouse.x
      @golf_ball.swing_start_y = args.inputs.mouse.y
    elsif args.inputs.mouse.click && @golf_ball.swing_state == :flying
      puts "Ball in flight, can't swing"
      # TODO: play sound cue
    end

    if args.inputs.mouse.up
      puts "Drag ended"
      if @golf_ball.swing_state == :swinging
        @golf_ball.swing_state = :flying
        swing_ball(@golf_ball, args)
        @strokes += 1
        # TODO: play sound cue
      end
    end

    if args.inputs.mouse.down
      puts "Dragging..."
      #if @golf_ball.swing_state == :waiting_for_swing
      #  @golf_ball.swing_state = :swinging
      #  @golf_ball.swing_end_x = args.inputs.mouse.x
      #  @golf_ball.swing_end_y = args.inputs.mouse.y
      # TODO: play sound cue
      #end
    end
  end
end

GAMEPLAY_SCENE = GameplayScene.new($gtk.args)
