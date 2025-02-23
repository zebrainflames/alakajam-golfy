# frozen-string-literal: true

require_relative 'scene'
require_relative 'palettes'

class OutroScene < Scene
  def update(args)
  end

  def render(args)
    args.outputs.background_color = BACKGROUND_COLOR
    args.outputs.labels << [args.grid.w / 2.0, 40.from_top, 'Thanks for playing!', 5, 1, 200, 200, 200]

    args.outputs.labels << [args.grid.w / 2.0, 120.from_top, "You took #{args.state.total_strokes} strokes to complete the game", 2, 1, 200, 200, 200]
  end
end

OUTRO_SCENE = OutroScene.new($args)
