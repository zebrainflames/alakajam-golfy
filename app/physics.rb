# frozen-string-literal: true

GRAVITY_SCALE = 2.7 # this is a magic scaling number to tune gravity strength and thus game feel

def predict_trajectory(planets, dynamic_body, args, predict_steps = 160)
  points = []
  sim_body = dynamic_body.dup

  dx, dy = swing_direction(sim_body, args)
  sim_body.vx = dx
  sim_body.vy = dy

  dt = 1.0 / 60.0

  predict_steps.times do
    apply_gravity(planets, sim_body, dt)
    sim_body.x += sim_body.vx * dt
    sim_body.y += sim_body.vy * dt
    points << { x: sim_body.x, y: sim_body.y }
  end

  points
end

def swing_direction(dynamic_body, args)
  drag_x = dynamic_body.swing_start_x - args.inputs.mouse.x
  drag_y = dynamic_body.swing_start_y - args.inputs.mouse.y
  drag_distance = Math.sqrt(drag_x**2 + drag_y**2)

  # we use a non-linear power function for a nicer game feel; enough power on small drags to
  # get moving but long drags don't send us out into the void of space
  swing_power = (drag_distance**1.2) * 0.1 # ~magic~ numbers again 8)

  if drag_distance > 0.01
    dir_x = drag_x / drag_distance
    dir_y = drag_y / drag_distance
  else 
    dir_x = 0
    dir_y = 0
  end

  [dir_x * swing_power, dir_y * swing_power]
end

def swing_ball(dynamic_body, args)
  dx, dy = swing_direction(dynamic_body, args)

  dynamic_body.vx = dx
  dynamic_body.vy = dy
end

def apply_gravity(planets, dynamic_body, dt)
  planets.each do |planet|
    dx = planet.x - dynamic_body.x
    dy = planet.y - dynamic_body.y
    r2 = dx**2 + dy**2
    r3 = r2 * Math.sqrt(r2)
    dynamic_body.vx += dx * planet.mass / r3 * dt * GRAVITY_SCALE
    dynamic_body.vy += dy * planet.mass / r3 * dt * GRAVITY_SCALE
  end
end

def physics_update(planets, dynamic_body)
  return if dynamic_body.swing_state == :waiting_for_swing
  # DR uses a fixed timestep of 1/60 seconds; this is just the delta time value for
  # the euler integraiton in this simulation (called every frame)
  dt = 1.0 / 30.0

  apply_gravity(planets, dynamic_body, dt)

  # do collisions checks; it's done as a separate loop to separate velocity updates from gravity
  # and collisions to get them right. If they're done in the same loop, either the ball tunnels into bodies,
  # or some planet's gravity is not applied correctly, for example!
  bounced = false
  planets.each do |planet|
    dx = planet.x - @golf_ball.x
    dy = planet.y - @golf_ball.y
    r2 = dx**2 + dy**2
    combined_radius = planet.radius + dynamic_body.radius
    next unless r2 < combined_radius**2 # skip to next planet on no collision

    #puts "COLLISION"
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
    
    bounce_factor = 0.83 # some ~magic~ numbers to tune the bounce
    dynamic_body.vx -= 2 * dot_product * normal_x * bounce_factor
    dynamic_body.vy -= 2 * dot_product * normal_y * bounce_factor

    # apply some friction to the ball to slow it down for decent gameplay
    #bounce_friction = 0.9
    #dynamic_body.vx *= bounce_friction
    #dynamic_body.vy *= bounce_friction
  end

  # if we bounced, apply friction to simulate rolling on the ground etc.
  if bounced
    bounce_friction = 0.9
    dynamic_body.vx *= bounce_friction
    dynamic_body.vy *= bounce_friction


    # TODO: also add some angular velocity in the direction of movement to make it look like we're simulating
    # rolling physics
  end

  # TODO: emit signal for collision sound effect and ball state changes here instead of setting state directly
  # would be cleaner to manage ball state elsewhere and use this just for the physics
  # if the ball bounced; mark it's state as ready to be hit again
  if dynamic_body.swing_state && bounced && dynamic_body.swing_state != :ready
    dynamic_body.swing_state = :ready
    puts 'Ball ready to be hit again!'
  end

  # fake 'air' drag to slow down the ball in case it does not hit anything (to prevent stable orbits)
  if !bounced && dynamic_body.swing_state == :flying
    air_drag = 0.99999
    dynamic_body.vx *= air_drag
    dynamic_body.vy *= air_drag
  end

  dynamic_body.x += dynamic_body.vx * dt
  dynamic_body.y += dynamic_body.vy * dt

  return bounced # eww...
end
