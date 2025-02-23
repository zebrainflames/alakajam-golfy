# frozen-string-literal: true

require_relative 'audio_bus'
require_relative 'gameplay'
require_relative 'intro'
require_relative 'options_menu'
require_relative 'outro'


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
  if need_reload?
    puts 'Reloading scenes...'
    init_scenes(args)
  end

  unless args.state.settings
    args.state.settings = {
      volume: 0.8,
      fullscreen: false
    }
  end
  args.state&.current_scene&.tick(args)
end

puts 'main.rb loaded'
