# frozen-string-literal: true

require_relative 'scene'

class OptionsMenuScene < Scene
  def update(args)
    # Options menu update logic here
  end

  def render(args)
    args.outputs.background_color = [50, 50, 50]
    args.outputs.labels << [args.grid.w / 2.0, 40.from_top, 'Options', 5, 1, 200, 200, 200]
    # Options menu rendering logic here
  end
end

OPTIONS_MENU_SCENE = OptionsMenuScene.new($args)
