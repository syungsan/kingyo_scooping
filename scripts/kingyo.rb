#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

require "dxruby"

if __FILE__ == $0 then
  require "../lib/common"
  KINGYO_IMAGES = ["../images/kingyo03.png", "../images/demekin_black.png"]
else
  require "./lib/common"
  KINGYO_IMAGES = ["./images/kingyo03.png", "./images/demekin_black.png"]
end

KIND_OF_KINGYOS = ["red", "black"]
KINGYO_SHADOW_OFFSET_X = 5
KINGYO_SHADOW_OFFSET_Y = 5
KINGYO_ANIME_ADJUST_SPEED_RATIO = 0.1


class Kingyo < Sprite

  attr_accessor :id, :name, :is_drag
  attr_reader :width, :height, :mode

  include Common

  def initialize(x, y, kind_of, angle=0, scale=1, id=0, hover_speed=1, speed_lengths={"move"=>[1, 5], "escape"=>[1, 5]}, mode_lengths={"wait"=>[0, 100], "move"=>[0, 100], "escape"=>[0, 100]}, target=Window, is_drag=false)
    super()

    @images = []
    KINGYO_IMAGES.each do |kingyo_image|
      image0 = Image.load_tiles(kingyo_image, 4, 1, true)
      image1 = image0.map { |image| image.flush([64, 0, 0, 0]) }
      images = [image0, image1]
      @images.push(images)
    end
    @kind_of = kind_of

    image_src = @images[KIND_OF_KINGYOS.index(@kind_of)][0][0]
    render_target = RenderTarget.new(image_src.width * scale, image_src.height * scale)
    @images[KIND_OF_KINGYOS.index(@kind_of)].size.times do |index|
      @images[KIND_OF_KINGYOS.index(@kind_of)][index].map do |image|
        render_target.draw_scale(image_src.width * (scale - 1.0) * 0.5, image_src.height * (scale - 1.0) * 0.5, image, scale, scale)
        @images[KIND_OF_KINGYOS.index(@kind_of)][index][@images[KIND_OF_KINGYOS.index(@kind_of)][index].index(image)] = render_target.to_image
      end
    end
    render_target.dispose

    self.x = x
    self.y = y
    self.image = @images[KIND_OF_KINGYOS.index(@kind_of)][0][0]
    @width = self.image.width
    @height = self.image.height
    self.collision = [0, 0, @width, @height]
    self.target = target
    self.angle = angle
    @id = id
    @name = "#{kind_of}_kingyo"
    @is_drag = is_drag
    @mode_lengths = mode_lengths
    @speed_lengths = speed_lengths
    @hover_speed = hover_speed
    @anime_count = 0

    modes = ["wait", "move"]
    self.change_mode(modes[rand(2)])
  end

  def update
    @anime_count += @speed * KINGYO_ANIME_ADJUST_SPEED_RATIO if @speed
    @anime_count = 0 if @anime_count > @images[KIND_OF_KINGYOS.index(@kind_of)][0].size
    self.image = @images[KIND_OF_KINGYOS.index(@kind_of)][0][@anime_count.floor]
    @shadow_image = @images[KIND_OF_KINGYOS.index(@kind_of)][1][@anime_count.floor]

    case @mode
    when "wait"
      self.wait
    when "move"
      self.move
    when "escape"
      self.escape
    end
  end

  def change_mode(mode)

    @wait_count = 0
    @move_count = 0

    case mode
    when "wait"
      @wait_length = random_int(@mode_lengths["wait"][0], @mode_lengths["wait"][1])
      @speed = @hover_speed
    when "move"
      @move_length = random_int(@mode_lengths["move"][0], @mode_lengths["move"][1])
      @speed = rand_float(@speed_lengths["move"][0], @speed_lengths["move"][1])
      self.angle = rand(360)
    end
    @mode = mode
  end

  def wait
    if @wait_count > @wait_length then
      self.change_mode("move")
    else
      @wait_count += 1
    end
  end

  def move
    if @move_count > @move_length then
      self.change_mode("wait")
    else
      radian = (self.angle + 270) * (Math::PI / 180)
      self.x += Math.cos(radian) * @speed
      self.y += Math.sin(radian) * @speed
      @move_count += 1
    end
  end

  def escape

  end

  def draw
    self.target.draw_ex(self.x + KINGYO_SHADOW_OFFSET_X, self.y + KINGYO_SHADOW_OFFSET_Y, @shadow_image, {:angle=>self.angle})
    self.target.draw_ex(self.x, self.y, self.image, {:angle=>self.angle})
  end
end


if __FILE__ == $0 then

  Window.width = 1920
  Window.height = 1080

  require "./border"
  include Common

  line_width = 50
  border_top = Border.new(0, 0, Window.width, line_width, 0)
  border_left = Border.new(0, 0, line_width, Window.height, 1)
  border_right = Border.new(Window.width - line_width, 0, line_width, Window.height, 2)
  border_bottom = Border.new(0, Window.height - line_width, Window.width, line_width, 3)
  borders = [border_top, border_left, border_right, border_bottom]

  kingyos = []
  60.times do
    kingyo = Kingyo.new(0, 0, KIND_OF_KINGYOS[rand(2)], rand(360), rand_float(0.5, 1.0))
    kingyo.x = random_int(border_left.x + border_left.width, border_right.x - kingyo.width)
    kingyo.y = random_int(border_top.y + border_top.height, border_bottom.y - kingyo.height)
    kingyos.push(kingyo)
  end

  Window.bgcolor = C_WHITE
  Window.loop do

    borders.each do |border|
      border.draw
    end

    kingyos.each do |kingyo|
      kingyo.update
      kingyo.draw
    end

    Sprite.check(borders + kingyos)
  end
end