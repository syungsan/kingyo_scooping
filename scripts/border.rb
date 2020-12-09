#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

require "dxruby"


class Border < Sprite

  attr_accessor :id, :name, :is_drag
  attr_reader :width, :height

  def initialize(x, y, width, height, color=C_RED, id=0, target=Window, is_drag=false)
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
  end

  # 何かに当たっている間の処理（能動）
  def shot(obj)
  end
end


if __FILE__ == $0

  WINDOW_WIDTH = 1280
  WINDOW_HEIGHT = 720

  Window.width = WINDOW_WIDTH
  Window.height = WINDOW_HEIGHT

  line_width = 50

  border_top = Border.new(0, 0, Window.width, line_width)
  border_left = Border.new(0, 0, line_width, Window.height)
  border_right = Border.new(Window.width - line_width, 0, line_width, Window.height)
  border_bottom = Border.new(0, Window.height - line_width, Window.width, line_width)

  borders = [border_top, border_left, border_right, border_bottom]

  Window.loop do
    borders.each do |border|
      border.draw
    end
  end
end