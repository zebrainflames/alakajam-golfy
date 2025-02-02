# frozen_string_literal: true

# Scene implements the basic structure for a scene in this game
class Scene
  attr_accessor :update, :render, :state

  def initialize(_args)
    @state = {}
  end

  def update(args)
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end

  def render(args)
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end

  def tick(args)
    update(args)
    render(args)
  end
end
