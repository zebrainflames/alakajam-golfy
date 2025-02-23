# frozen-string-literal: true

module PlanetConstants
  SMALL_PLANET_MASS = 45_000.0
  SMALL_PLANET_RADIUS = 32.0
  MEDIUM_PLANET_MASS = 120_000.0
  MEDIUM_PLANET_RADIUS = 64.0
  BIG_PLANET_MASS = 240_000.0
  BIG_PLANET_RADIUS = 96.0
end

class LevelLoader
  include PlanetConstants

  # Level data constants (hardcoded levels)
  # Could do with a nicer way to create these, but no time for that in the jam ;)
  LEVEL_DATA = {
    1 => {
      planets: [
        { type: :medium_rock, x: 640.0, y: 360.0, mass: MEDIUM_PLANET_MASS, radius: MEDIUM_PLANET_RADIUS }
      ],
      ball: { x: 640.0, y: 360.0 + 64.0 + 11.0 },
      flag: { x: 640.0, y: 360.0 - 64.0 - 8.0, angle: 180.0 }
    },
    2 => {
      planets: [
        { type: :big_rock, x: 350.0, y: 360.0, mass: BIG_PLANET_MASS, radius: BIG_PLANET_RADIUS },
        { type: :big_rock, x: 350.0.from_right, y: 360.0, mass: BIG_PLANET_MASS, radius: BIG_PLANET_RADIUS }
      ],
      ball: { x: 350.0.from_right + BIG_PLANET_RADIUS + 11, y: 360.0 },
      flag: { x: 350.0.from_left - BIG_PLANET_RADIUS - 8.0, y: 360.0, angle: 90.0 }
    },
    3 => {
      planets: [
        { type: :small_rock, x: 300.0, y: 520.0, mass: SMALL_PLANET_MASS, radius: SMALL_PLANET_RADIUS },
        { type: :medium_rock, x: 800.0, y: 220.0, mass: MEDIUM_PLANET_MASS, radius: MEDIUM_PLANET_RADIUS }
      ],
      ball: { x: 300.0, y: 520.0 + 32.0 + 10.0 },
      flag: { x: 800.0 + MEDIUM_PLANET_RADIUS - 14.0, y: 220.0 + MEDIUM_PLANET_RADIUS - 14.0, angle: -45.0 }
    },
    4 => {
      planets: [
        { type: :medium_rock, x: 384, y: 256 },
        { type: :small_rock, x: 640, y: 640 }
      ],
      ball: { x: 384 - 64 - 11, y: 256 },
      flag: { x: 640 + 32 + 8, y: 640, angle: 270.0 }
    },
    5 => { # NOTE: this is currently a bit hard; it's a precision shot thing
      planets: [
        # { type: :big_rock, x: 512, y: 512 },
        { type: :big_rock, x: 812, y: 412 },
        { type: :small_rock, x: 212, y: 112 },
      ],
      ball: { x: 812 + 96 + 11, y: 412 },
      flag: { x: 212 - 32 - 8, y: 112, angle: 90 }
    },
    # Add more levels here...
  }

  def self.load_level(level_number = 1)
    level_data_raw = LEVEL_DATA[level_number]

    if level_data_raw
      {
        planets: level_data_raw[:planets].map { |planet_data| create_planet(planet_data) },
        ball: create_ball(level_data_raw[:ball]),
        flag: create_flag(level_data_raw[:flag])
      }
    else
      puts "Error: Level data not found for level #{level_number}"
      nil # Or raise an exception, or return default level data
    end
  end

  private

  class << self
    def create_planet(data)
      case data[:type]
      when :small_rock
        { x: data[:x], y: data[:y], mass: SMALL_PLANET_MASS, radius: SMALL_PLANET_RADIUS, type: data[:type] }
      when :medium_rock
        { x: data[:x], y: data[:y], mass: MEDIUM_PLANET_MASS, radius: MEDIUM_PLANET_RADIUS, type: data[:type] }
      when :big_rock
        { x: data[:x], y: data[:y], mass: BIG_PLANET_MASS, radius: BIG_PLANET_RADIUS, type: data[:type] }
      else # Default to medium rock if type is not recognized or nil
        { x: data[:x], y: data[:y], mass: MEDIUM_PLANET_MASS, radius: MEDIUM_PLANET_RADIUS, type: :medium_rock }
      end
    end

    def create_ball(data)
      { x: data[:x], y: data[:y], vx: 0.0, vy: 0.0, av: 0.0, radius: 11.0,
        mass: 1.0, swing_state: :waiting_for_swing }
    end

    def create_flag(data)
      { x: data[:x], y: data[:y], radius: 8.0, angle: data[:angle] || 0.0 }
    end
  end
end
