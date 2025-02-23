# frozen-string-literal: true

require_relative 'scene'
require_relative 'palettes'

class IntroScene < Scene
  def update(args)
    if args.inputs.keyboard.key_down.enter || args.inputs.keyboard.key_down.space
      switch_scene(args, :gameplay)
    end
  end

  def render(args)
    args.outputs.background_color = BACKGROUND_COLOR
    args.outputs.labels << [args.grid.w / 2.0, 40.from_top, "Welcome to Gravity Swing!", 5, 1, 200, 200, 200]
    args.outputs.labels << [args.grid.w / 2.0, 120.from_top, 'Click and drag with the mouse to swing at the meteor', 2, 1, 200, 200, 200]
    args.outputs.labels << [args.grid.w / 2.0, 160.from_top, 'Get it to the red flag. Hitting ground allows you to swing again.', 2, 1, 200, 200, 200]
    args.outputs.labels << [args.grid.w / 2.0, 200.from_top, 'Press "SPACE" to begin!', 2, 1, 200, 200, 200]
  end
end

INTRO_SCENE = IntroScene.new($args)
