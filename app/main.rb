# frozen-string-literal: true

require_relative 'audio_bus'
require_relative 'gameplay'
require_relative 'intro'
require_relative 'options_menu'
require_relative 'outro'
require_relative 'palettes'

def init_scenes(args)
  @reload_needed = false
  args.state.scenes = {}
  args.state.scenes[:gameplay] = GAMEPLAY_SCENE
  args.state.scenes[:options] = OPTIONS_MENU_SCENE
  args.state.scenes[:outro] = OUTRO_SCENE
  args.state.scenes[:intro] = INTRO_SCENE
  args.state.current_scene_id = :intro
  args.state.current_scene = args.state.scenes[args.state.current_scene_id]
end

def switch_scene(args, scene)
  return if args.state.current_scene_id == scene

  args.state.previous_scene = args.state.current_scene unless args.state.current_scene.nil?
  args.state.current_scene = args.state.scenes[scene]
  args.state.current_scene_id = scene
end

@reload_needed = true
def need_reload?
  @reload_needed || Kernel.tick_count.zero?
end

# @params args [GTK::Args]
def tick(args)
  # straight from DR docs: https://docs.dragonruby.org/static/docs.html#----consider-adding-pause-when-game-is-in-background
  if (!args.inputs.keyboard.has_focus && args.gtk.production && Kernel.tick_count != 0)
    args.outputs.background_color = BACKGROUND_COLOR
    args.outputs.labels << { x: 640,
                             y: 360,
                             text: "Game Paused (click to resume).",
                             alignment_enum: 1,
                             r: 255, g: 255, b: 255 }
    return
  end

  if need_reload?
    puts 'Reloading scenes...'
    init_scenes(args)
  end

  args.state&.current_scene&.tick(args)
end

