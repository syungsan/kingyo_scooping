#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

# card.rb Ver 0.9.1
# 汎用カードキャラクタ

require "dxruby"


class Card < Sprite

  attr_accessor :mode, :is_drag, :flip_speed
  attr_reader :id, :width, :height, :is_flip, :text

  def initialize(x=0, y=0, width=100, height=200, is_flip=false, front_color=C_WHITE, back_color=C_WHITE, option={})
    option = {:text=>"", :flip_speed=>1, :is_drag=>false, :id=>0, :name=>"card", :target=>Window}.merge(option)

    self.x = x
    self.y = y
    @width = width
    @height = height

    self.target = option[:target]
    @front_image = Image.new(@width, @height, front_color)
    @back_image = Image.new(@width, @height, back_color)
    @text = option[:text]
    @is_drag = option[:is_drag]
    @id = option[:id]
    @scale_x = 1.0
    @degree = 0

    @is_flip = is_flip
    @flip_speed = option[:flip_speed]

    @mode = :wait
  end

  def set_pos(x, y)
    self.x = x
    self.y = y
  end

  def set_image(front_image, back_image)
    image = Image.load(front_image)
    @front_image = RenderTarget.new(@width, @height).
      draw_scale(0, 0, image, @width / image.width.to_f, @height / image.height.to_f, 0, 0).update.to_image
    image = Image.load(back_image)
    @back_image = RenderTarget.new(@width, @height).
      draw_scale(0, 0, image, @width / image.width.to_f, @height / image.height.to_f, 0, 0).update.to_image
    image.dispose
    self.constract
  end

  def set_text(front_text, back_text, font_size, front_color, back_color, font_type="ＭＳ Ｐゴシック")
    front_font = Font.new(font_size, font_type)
    back_font = Font.new(font_size, font_type)
    @front_image.draw_font_ex((@width - font_size) * 0.5,
                              (@height - font_size) * 0.5, front_text, front_font, {:color=>front_color})
    @back_image.draw_font_ex((@width - font_size) * 0.5,
                             (@height - font_size) * 0.5, back_text, back_font, {:color=>back_color})
    self.constract
  end

  def constract
    unless @is_flip then
      self.image = @front_image
    else
      self.image = @back_image
    end
  end

  def update
    if @mode == :turn then
      @scale_x = Math.cos(@degree / 180.0 * Math::PI).abs
      if @degree == 90 or @degree == 270 then
        unless @is_flip then
          @is_flip = true
        else
          @is_flip = false
        end
        self.constract
      end
      @degree += self.flip_speed
      @degree = 0 if @degree == 360
    end
  end

  def draw
    self.target.draw_ex(self.x, self.y, self.image, {:scale_x=>@scale_x})
  end
end


if __FILE__ == $0

  card = Card.new(0, 0, 240, 320)
  card.set_pos((Window.width - card.width) * 0.5, (Window.height - card.height) * 0.5)
  card.set_text("鬱", "靨", card.width * 0.8, C_BLACK, C_BLACK)
  card.flip_speed = 3
  card.mode = :turn

  Window.loop do
    card.update
    card.draw
  end
end
