#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

require "dxruby"


class ScoreListBox

  attr_accessor :name,:id, :is_drag
  attr_reader :width, :height

  SHADOW_OFFSET_X = 10
  SHADOW_OFFSET_Y = 10

  def initialize(x=0, y=0, width=640, height=480, radius=20, fill_color=C_DEFAULT, border_color=C_BLUE,
                 frame_thickness=10, max_page_number=10, name="list_box", id=0, target=Window)
    @x = x
    @y = y
    @width = width
    @height = height
    @name = name
    @id = id
    @target = target
    @frame_image = Image.new(@width, @height)
    self.roundbox_fill(0, 0, @width, @height, radius, fill_color, @frame_image)
    @frame_thickness = frame_thickness
    @frame_thickness.times do |index|
      self.roundbox(index, index, @width - 1 - index, @height - 1 - index, radius, border_color, @frame_image)
    end
    @shadow = @frame_image.flush([64, 0, 0, 0])
    @down_layer = Image.new(@width - (@frame_thickness * 2), @height - (@frame_thickness * 2) * max_page_number)
    @up_layer = Image.new(@width - (@frame_thickness * 2), @height - (@frame_thickness * 2))
    @scroll_count = 0
  end

  def setItems(items, horizontal_division_ratios, colors, color_target_index, vertical_division=10)
    items.each_with_index do |item, i|
      vartical_part_height = (@height - (@frame_thickness * 2)) / vertical_division
      vertical_position = vartical_part_height * i
      horizontal_position = 0
      item.each_with_index do |itm, j|
        horizontal_division = (@width - (@frame_thickness * 2)) * horizontal_division_ratios[j] / horizontal_division_ratios.inject(:+).to_f
        p font_size = [horizontal_division / itm.length * 2, vartical_part_height].min
        font = Font.new(font_size)
        if j == color_target_index then
          color = colors[i]
        else
          color = C_ROYAL_BLUE
        end
        @down_layer.draw_font_ex(horizontal_position, vertical_position, itm, font, {:color=>color, :shadow=>true, :shadow_color=>[64, 64, 64]})
        horizontal_position += horizontal_division
      end
    end
    @up_layer.draw(0, 0, @down_layer)
  end

  def update
    # @scroll_count += 5
  end

  def draw
    @target.draw(@x + SHADOW_OFFSET_X, @y + SHADOW_OFFSET_Y, @shadow)
    @up_layer.clear
    @up_layer.draw(0, @scroll_count, @down_layer)
    @target.draw(@x + @frame_thickness, @y + @frame_thickness, @up_layer)
    @target.draw(@x, @y, @frame_image)
  end

  def roundbox(x1, y1, x2, y2, r, c, target)
    image = Image.new(r * 2, r * 2).circle(r, r, r, c)
    target.draw(x1, y1, image, 0, 0, r, r)
    target.draw(x2 - r, y1, image, r, 0, r, r)
    target.draw(x1, y2 - r, image, 0, r, r, r)
    target.draw(x2 - r, y2 - r, image, r, r, r, r)
    target.line(x1 + r, y1, x2 - r, y1, c)
    target.line(x2, y1 + r, x2, y2 - r, c)
    target.line(x2 - r, y2, x1 + r, y2, c)
    target.line(x1, y1 + r, x1, y2 - r, c)
    image.dispose
  end

  def roundbox_fill(x1, y1, x2, y2, r, c, target)
    image = Image.new(r * 2, r * 2).circle_fill(r, r, r, c)
    target.draw(x1, y1, image, 0, 0, r, r)
    target.draw(x2 - r, y1, image, r, 0, r, r)
    target.draw(x1, y2 - r, image, 0, r, r, r)
    target.draw(x2 - r, y2 - r, image, r, r, r, r)
    target.box_fill(x1 + r, y1, x2 - r, y2, c)
    target.box_fill(x1, y1 + r, x2, y2 - r, c)
    image.dispose
  end
end


if __FILE__ == $0 then

  require "../lib/dxruby/color"
  include Color

  Window.width = 1280
  Window.height = 720

  items = [["1位", "非常勤講師", "10000点", "金魚神"], ["2位", "アルバイト募集", "1000点", "金魚人"], ["3位", "ちづる", "100点", "レジェンドン"],
           ["4位", "神じゃね？", "10点", "スーパーカブ"], ["5位", "落ちこぼれ野郎", "1点", "良しヲくん"]]
  colors = [C_RED, C_PURPLE, C_BLUE, C_MAGENTA, C_ORANGE]

  list_box = ScoreListBox.new(25, 25, 1230, 670)
  list_box.setItems(items, [2, 7, 6, 4], colors, 3)

  Window.bgcolor = [127, 255, 212]
  Window.loop do
    list_box.update
    list_box.draw
  end
end
