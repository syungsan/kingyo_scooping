#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

require "dxruby"


class Border

  attr_accessor :name, :id, :target
  attr_reader :x, :y, :width, :height, :blocks

  THICKNESS = 50

  class Block <Sprite

    attr_accessor :name, :id, :is_drag
    attr_reader :width, :height

    def initialize(x, y, width, height, id=0, color=C_RED, name="block", target=Window, is_drag=false)
      super()

      self.x = x
      self.y = y
      self.collision = [0, 0, width, height]
      self.image = Image.new(width, height, color)
      self.target = target
      @name = name
      @id = id
      @is_drag = is_drag
      @width = self.image.width
      @height = self.image.height
    end

    def set_pos(x, y)
      self.x, self.y = x, y
    end

    def draw
      self.target.draw(self.x, self.y, self.image)
    end

    def hit(obj)
      unless obj.class == Block then
        obj.y = self.y + self.height + (obj.height * obj.collision_ratios[0]) if self.id == 0 and obj.collision_ratios[0]
        obj.x = self.x + self.width + (obj.height * obj.collision_ratios[1]) if self.id == 1 and obj.collision_ratios[1]
        obj.x = self.x - obj.width - (obj.height * obj.collision_ratios[2]) if self.id == 2 and obj.collision_ratios[2]
        obj.y = self.y - obj.height - (obj.height * obj.collision_ratios[3]) if self.id == 3 and obj.collision_ratios[3]
      end
    end
  end

  def initialize(x, y, width, height, name="border", id=0, target=Window)

    @x = x
    @y = y
    @width = width
    @height = height
    @target = target
    @name = name
    @id = id

    block_top = Block.new(@x - THICKNESS, @y - THICKNESS, @width + (THICKNESS * 2), THICKNESS, 0)
    block_left = Block.new(@x - THICKNESS, @y - THICKNESS, THICKNESS, @height + (THICKNESS * 2), 1)
    block_right = Block.new(@x + @width, @y - THICKNESS, THICKNESS, @height + (THICKNESS * 2), 2)
    block_bottom = Block.new(@x - THICKNESS, @y + @height, @width + (THICKNESS * 2), THICKNESS, 3)
    @blocks = [block_top, block_left, block_right, block_bottom]
  end

  def set_pos(x, y)
    @x = x
    @y = y
  end

  def draw
    @blocks.each do |block|
      block.draw
    end
  end

  def vanish
    @blocks.each do |block|
      block.vanish
    end
  end
end


if __FILE__ == $0 then

  Window.width = 1280
  Window.height = 720

  border = Border.new(100, 100, Window.width - 200, Window.height - 200)

  Window.loop do
    border.draw
  end
end
