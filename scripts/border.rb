#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

require "dxruby"

BORDER_COLLISION_FOR_KINGYO_ADJUST_TOP = 5
BORDER_COLLISION_FOR_KINGYO_ADJUST_LEFT = 50
BORDER_COLLISION_FOR_KINGYO_ADJUST_RIGHT = 50
BORDER_COLLISION_FOR_KINGYO_ADJUST_BOTTOM = 5


class Border < Sprite

  attr_accessor :id, :name, :is_drag
  attr_reader :width, :height

  def initialize(x, y, width, height, id=0, color=C_RED, target=Window, is_drag=false)
    super()

    self.x = x
    self.y = y
    self.collision = [0, 0, width, height]
    self.image = Image.new(width, height, color)
    self.target = target
    @name = "border"
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

  # 何かが当っている間の処理（受動）
  def hit(obj)

    if obj.name.include?("kingyo") then
      obj.y = self.y + self.height + BORDER_COLLISION_FOR_KINGYO_ADJUST_TOP if self.id == 0
      obj.x = self.x + self.width + BORDER_COLLISION_FOR_KINGYO_ADJUST_LEFT if self.id == 1
      obj.x = self.x - obj.width - BORDER_COLLISION_FOR_KINGYO_ADJUST_RIGHT if self.id == 2
      obj.y = self.y - obj.height - BORDER_COLLISION_FOR_KINGYO_ADJUST_BOTTOM if self.id == 3
    end
  end

  # 何かに当たっている間の処理（能動）
  def shot(obj)
  end
end


if __FILE__ == $0 then

  Window.width = 1280
  Window.height = 720

  line_width = 50

  border_top = Border.new(0, 0, Window.width, line_width, 0)
  border_left = Border.new(0, 0, line_width, Window.height, 1)
  border_right = Border.new(Window.width - line_width, 0, line_width, Window.height, 2)
  border_bottom = Border.new(0, Window.height - line_width, Window.width, line_width, 3)
  borders = [border_top, border_left, border_right, border_bottom]

  Window.loop do
    borders.each do |border|
      border.draw
    end
  end
end