# frozen-string-literal: true

def apply_gravity(planets, dynamic_body, dt)
  planets.each do |planet|
    dx = planet.x - dynamic_body.x
    dy = planet.y - dynamic_body.y
    r2 = dx**2 + dy**2
    r3 = r2 * Math.sqrt(r2)
    dynamic_body.vx += dx * planet.mass / r3 * dt
    dynamic_body.vy += dy * planet.mass / r3 * dt
  end
end

def physics_update(planets, dynamic_body)
  # DR uses a fixed timestep of 1/60 seconds; this is just the delta time value for
  # the euler integraiton in this simulation (called every frame)
  dt = 1.0 / 30.0

  apply_gravity(planets, dynamic_body, dt)

  # do collisions checks; it's done as a separate loop to separate velocity updates from gravity:E
  # and collisions to get them right. If they're done in the same loop, either the ball tunnels into bodies,
  # or some planet's gravity is not applied correctly, for example!
  bounced = false
  planets.each do |planet|
    dx = planet.x - @golf_ball.x
    dy = planet.y - @golf_ball.y
    r2 = dx**2 + dy**2
    combined_radius = planet.radius + dynamic_body.radius
    next unless r2 < combined_radius**2 # skip to next planet on no collision

    bounced = true
    dist = Math.sqrt(r2)
    overlap = dist - combined_radius
    # move the dynamic body out of the planet
    dynamic_body.x += overlap * dx / dist
    dynamic_body.y += overlap * dy / dist
    # reflect the dynamic body's velocity based on collision normal and current velocity
    # ( NOTE: remember to update to _relative velocity_ if implementing collisions with moving bodies!)
    normal_x = dx / dist
    normal_y = dy / dist
    dot_product = dynamic_body.vx * normal_x + dynamic_body.vy * normal_y
    # NOTE: this friction/bounce amount could come from planet definition, or be a global constant
    bounce_factor = 0.73
    dynamic_body.vx -= 2 * dot_product * normal_x * bounce_factor
    dynamic_body.vy -= 2 * dot_product * normal_y * bounce_factor
  end

  # TODO: emit signal for collision sound effect and ball state changes here instead of setting state directly
  # would be cleaner to manage ball state elsewhere and use this just for the physics
  # if the ball bounced; mark it's state as ready to be hit again
  if dynamic_body.swing_state && bounced && dynamic_body.swing_state != :ready
    dynamic_body.swing_state = :ready
    puts 'Ball ready to be hit again!'
  end

  dynamic_body.x += dynamic_body.vx * dt
  dynamic_body.y += dynamic_body.vy * dt
end
