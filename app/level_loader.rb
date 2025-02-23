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
  LEVEL_DATA = {
    1 => {
      planets: [
        { type: :medium_rock, x: 640.0, y: 360, mass: MEDIUM_PLANET_MASS, radius: MEDIUM_PLANET_RADIUS }
      ],
      ball: { x: 640, y: 360 + 64 + 11 },
      flag: { x: 640, y: 360 - 64 - 8, angle: 180.0 }
    },
    2 => {
      planets: [
        { type: :big_rock, x: 300, y: 400, mass: BIG_PLANET_MASS, radius: BIG_PLANET_RADIUS }
      ],
      ball: { x: 100, y: 100 },
      flag: { x: 500, y: 600 }
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
      puts "creating ballz"
      { x: data[:x], y: data[:y], vx: 0.0, vy: 0.0, av: 0.0, radius: 11.0,
        mass: 1.0, swing_state: :waiting_for_swing }
    end

    def create_flag(data)
      { x: data[:x], y: data[:y], radius: 8.0, angle: data[:angle] || 0.0 }
    end
  end
end
