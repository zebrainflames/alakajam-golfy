# frozen-string-literal: true

require_relative 'level_loader.rb'
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
  w: 192,
  h: 192,
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

  LevelAmount = 5

  def initialize(args)
    super

    @currrent_level = 0
    @total_strokes = 0
    @strokes = 0
    load_level()
  end

  def load_level(number = nil)
    @level_won = false
    @level_won_sound_played = false
    @total_strokes += @strokes
    @strokes = 0
    @currrent_level += 1
    return if @currrent_level > LevelAmount
    @currrent_level = number if number != nil
    new_level_data = LevelLoader.load_level(@currrent_level)
  
    if new_level_data
      @level_data = new_level_data
      reset_planets
    else
      puts "ERROR: could not load level data"
      nil
    end
  end

  def ball_out_of_bounds?(args)
    @golf_ball.x < 0 || @golf_ball.x > args.grid.w || @golf_ball.y < 0 || @golf_ball.y > args.grid.h
  end

  def ticks_since_last_collision
    t = Kernel.tick_count
    @last_collision_tick ||= 0
    delta = t - @last_collision_tick
    @last_collision_tick = t
    delta
  end

  def ball_moving?(ball)
    (ball.vx.abs > 5 || ball.vy.abs > 5) && ticks_since_last_collision > 30
  end

  def update(args)
    if @level_won
      if @currrent_level > LevelAmount
        args.state.total_strokes = @total_strokes
        switch_scene(args, :outro)
        return
      end

      if args.inputs.keyboard.key_down.space
        load_level
      end

      return
    end

    player_input(args)
    ball_bounced = physics_update(@planets, @golf_ball) if can_update_physics?

    
    args.outputs.sounds << 'sounds/thud_new.wav' if ball_bounced && ball_moving?(@golf_ball)

    if ball_out_of_bounds?(args)
      # TODO: display some sort of particle fx at pont of impact
      reset_planets
      args.outputs.sounds << 'sounds/boom.wav'
    end

    if ball_collides_with_flag?
      @level_won = true
      args.outputs.sounds << 'sounds/level_clear.wav' unless @level_won_sound_played
      @level_won_sound_played = true
    end
  end

  def render(args)
    args.outputs.background_color = BACKGROUND_COLOR
    #args.outputs.labels << [args.grid.w / 2.0, 700, 'Physics testing', 5, 1, 200, 200, 200]
    if @level_won
      args.outputs.labels << [args.grid.w / 2.0, 700, "Level complete in #{@strokes} strokes.", 5, 1, 200, 200, 200]
      args.outputs.labels << [args.grid.w / 2.0, 650, 'Press "SPACE" for the next level.', 5, 1, 200, 200, 200]
    end

    args.outputs.labels << [20.from_left, 20.from_top, "Strokes: #{@strokes}", 5, 4, 200,
                            200, 200] unless @level_won
    # draw a line from ball to mouse cursor if player is dragging
    if @golf_ball.swing_state == :swinging
      render_trajectory_projection(args)
    end

    args.outputs.sprites << @planets.map do |planet|
      case planet[:type]
      when :medium_rock
        planet.merge(PLANET_MED_ROCK)
      when :small_rock
        planet.merge(PLANET_SMALL_ROCK)
      when :big_rock
        planet.merge(PLANET_BIG_ROCK)
      end
    end

    args.outputs.sprites << @golf_ball.merge(BALL_SPRITE)

    args.outputs.sprites << @flag.merge(FLAG_SPRITE)
  end

  def reset_planets
    puts "Resetting level data from #{@level_data.inspect}"
    @planets = @level_data[:planets].dup
    @golf_ball = @level_data[:ball].dup
    puts "Ball is now at #{@golf_ball.inspect}"
    @flag = @level_data[:flag].dup
  end

  private 

  def ball_collides_with_flag?
    dx = @golf_ball.x - @flag[:x]
    dy = @golf_ball.y - @flag[:y]
    distance = Math.sqrt(dx**2 + dy**2)
    distance < @golf_ball.radius + @flag.radius
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
        args.outputs.sounds << 'sounds/swing_hit.wav'
      end
    end
  end
end

GAMEPLAY_SCENE = GameplayScene.new($gtk.args)
