#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

require "dxruby"


class ScoreListBox

  attr_accessor :shadow_x, :shadow_y, :name,:id, :target, :is_drag
  attr_reader :width, :height, :mode

  if __FILE__ == $0 then
    require "../lib/dxruby/roundbox"
  else
    require "./lib/dxruby/roundbox"
  end

  SHADOW_OFFSET_X = 10
  SHADOW_OFFSET_Y = 10
  FONT_SIZE_RATO = 0.8
  SCROLL_SPEED = 10

  def initialize(x=0, y=0, width=640, height=480, scroll_speed=10, radius=20, fill_color=C_DEFAULT, border_color=C_BLUE,
                 frame_thickness=10, max_page_number=10, name="list_box", id=0, target=Window)
    @x = x
    @y = y
    @width = width
    @height = height

    @name = name
    @id = id
    @target = target

    @frame_image = Image.new(@width, @height)
    @frame_image.roundbox_fill(0, 0, @width, @height, radius, fill_color)

    @frame_thickness = frame_thickness
    @frame_thickness.times do |index|
      @frame_image.roundbox(index, index, @width - 1 - index, @height - 1 - index, radius, border_color)
    end
    @shadow = @frame_image.flush([64, 0, 0, 0])

    @max_page_number = max_page_number
    @down_layer = Image.new(@width - (@frame_thickness * 2), (@height - (@frame_thickness * 2)) * @max_page_number)
    @up_layer = Image.new(@width - (@frame_thickness * 2), @height - (@frame_thickness * 2), C_BLACK)

    @shadow_x = SHADOW_OFFSET_X
    @shadow_y = SHADOW_OFFSET_Y

    @scroll_speed = scroll_speed.round
    @scroll_count = 0
    @page_number = 1
  end

  def set_items(items, horizontal_division_ratios, default_text_color, target_colors, color_target_index,
                font_type="ＭＳ Ｐゴシック", vertical_division=10)

    if items.size <= vertical_division * @max_page_number then
      items.each_with_index do |item, i|
        vertical_part_height = (@height - (@frame_thickness * 2)) / vertical_division
        horizontal_position = 0

        item.each_with_index do |itm, j|
          horizontal_division = (@width - (@frame_thickness * 2)) *
            horizontal_division_ratios[j] / horizontal_division_ratios.inject(:+).to_f

          font_size = [horizontal_division / itm.length * 2, vertical_part_height].min * FONT_SIZE_RATO
          font = Font.new(font_size, font_type)
          if j == color_target_index then
            color = target_colors[i]
          else
            color = default_text_color
          end
          vertical_position = vertical_part_height * i + ((vertical_part_height - font_size) * 0.5)
          @down_layer.draw_font_ex(horizontal_position, vertical_position, itm, font,
                                   {:color=>color, :shadow=>true, :shadow_color=>[64, 64, 64]})
          horizontal_position += horizontal_division
        end
      end
      @up_layer.draw(0, 0, @down_layer)
      @max_page_number = items.size / vertical_division + 1
    end
  end

  def scroll_up
    @mode = :up
  end

  def scroll_down
    @mode = :down
  end

  def update
    if @mode == :up and @page_number > 1 then
      if @scroll_count < -1 * @up_layer.height * (@page_number - 2)then
        @scroll_count += @scroll_speed
      else
        @mode = :wait
        @page_number -= 1
      end
    end
    if @mode == :down and @page_number < @max_page_number then
      if @scroll_count > -1 * (@up_layer.height * @page_number) then
        @scroll_count -= @scroll_speed
      else
        @mode = :wait
        @page_number += 1
      end
    end
  end

  def draw
    @target.draw(@x + @shadow_x, @y + @shadow_y, @shadow)
    @up_layer.clear
    @up_layer.draw(0, @scroll_count, @down_layer)
    @target.draw(@x + @frame_thickness, @y + @frame_thickness, @up_layer)
    @target.draw(@x, @y, @frame_image)
  end
end


if __FILE__ == $0 then

  require "../lib/dxruby/color"
  include Color

  SCROLL_SPEED_RATIO = 0.015

  Window.width = 1280
  Window.height = 720

  items = [["1位", "非常勤講師", "10000点", "金魚神"], ["2位", "アルバイト募集", "1000点", "金魚人"], ["3位", "ちづる", "100点", "レジェンドン"],
           ["4位", "神じゃね？", "10点", "スーパーカブ"], ["5位", "落ちこぼれ野郎", "1点", "良しヲくん"]]

  colors = [C_RED, C_PURPLE, C_BLUE, C_MAGENTA, C_ORANGE]

  list_box = ScoreListBox.new(25, 25, 1230, 670, Window.height * SCROLL_SPEED_RATIO)
  list_box.set_items(items, [3, 8, 7, 4], C_ROYAL_BLUE, colors, 3)

  Window.bgcolor = [127, 255, 212]
  Window.loop do
    list_box.update
    list_box.draw
    if Input.key_push?(K_UP) then
      list_box.scroll_up
    end
    if Input.key_push?(K_DOWN) then
      list_box.scroll_down
    end
  end
end
