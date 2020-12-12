#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

require "dxruby"

if __FILE__ == $0 then
  require "../lib/common"
  BOSS_IMAGE = "../images/boss_kingyo.PNG"
else
  require "./lib/common"
  BOSS_IMAGE = "./images/boss_kingyo.PNG"
end

BOSS_SHADOW_OFFSET_X = 5
BOSS_SHADOW_OFFSET_Y = 5

BOSS_ANIME_ADJUST_SPEED_RATIO = 0.05
BOSS_CATCHED_ANIME_SPEED_RATIO = 1.5


class Boss < Sprite

  attr_accessor :id, :name, :is_drag, :mode, :is_reserved
  attr_reader :width, :height

  include Common

  def initialize(x, y, angle=0, scale=1, id=0, speed_ranges={:wait=>[0, 1], :move=>[1, 3], :against=>[1, 3]}, mode_ranges={:wait=>[0, 200], :move=>[0, 100], :against=>[0, 200]}, target=Window, is_drag=false)
    super()

    image0 = Image.load_tiles(BOSS_IMAGE, 4, 1, true)
    image1 = image0.map { |image| image.flush([64, 0, 0, 0]) }
    image01s = [image0, image1]

    @images = []
    render_target = RenderTarget.new(image01s[0][0].width * scale, image01s[0][0].height * scale)
    image01s.each do |image01|
      images = []
      image01.map do |image|
        render_target.draw_scale(image.width * (scale - 1.0) * 0.5, image.height * (scale - 1.0) * 0.5, image, scale, scale)
        images.push(render_target.to_image)
        image.dispose
      end
      @images.push(images)
    end
    render_target.dispose

    self.x = x
    self.y = y
    self.image = @images[0][0]
    @width = self.image.width
    @height = self.image.height
    self.collision = [0, 0, @width, @height]
    self.target = target
    self.angle = angle
    @id = id
    @name = "boss"
    @is_drag = is_drag
    @mode_ranges = mode_ranges
    @speed_ranges = speed_ranges
    @anime_count = 0

    modes = [:wait, :move]
    self.change_mode(modes[rand(2)])
  end

  def update
    @anime_count += @speed * BOSS_ANIME_ADJUST_SPEED_RATIO if @speed
    @anime_count = 0 if @anime_count > @images[0].size
    self.image = @images[0][@anime_count.floor]
    @shadow_image = @images[1][@anime_count.floor]

    case @mode
    when :wait
      self.wait

    when :move
      self.move

    when :escape
      self.escape

    when :catched
      self.catched

    when :reserved
      modes = [:wait, :move]
      self.change_mode(modes[rand(2)])
    end
  end

  def change_mode(mode)

    @wait_count = 0
    @move_count = 0

    case mode
    when :wait
      @wait_length = random_int(@mode_ranges[:wait][0], @mode_ranges[:wait][1])
      @speed = rand_float(@speed_ranges[:wait][0], @speed_ranges[:wait][1])
      @old_speed = @speed
    when :move
      @move_length = random_int(@mode_ranges[:move][0], @mode_ranges[:move][1])
      @speed = rand_float(@speed_ranges[:move][0], @speed_ranges[:move][1])
      @old_speed = @speed
      self.angle = rand(360)
    end
    @mode = mode
  end

  def wait
    if @wait_count > @wait_length then
      self.change_mode(:move)
    else
      @wait_count += 1
    end
  end

  def move
    if @move_count > @move_length then
      self.change_mode(:wait)
    else
      radian = (self.angle + 270) * (Math::PI / 180)
      self.x += Math.cos(radian) * @speed
      self.y += Math.sin(radian) * @speed
      @move_count += 1
    end
  end

  def escape

  end

  def catched
    @speed = @old_speed * BOSS_CATCHED_ANIME_SPEED_RATIO if @speed == @old_speed
  end

  def hit(obj)

  end

  def draw
    self.target.draw_ex(self.x + BOSS_SHADOW_OFFSET_X, self.y + BOSS_SHADOW_OFFSET_Y, @shadow_image, {:z=>self.z, :angle=>self.angle})
    self.target.draw_ex(self.x, self.y, self.image, {:z=>self.z, :angle=>self.angle})
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

  bosss = []
  20.times do
    boss = Boss.new(0, 0, rand(360), rand_float(0.5, 1.0))
    boss.x = random_int(border_left.x + border_left.width, border_right.x - boss.width)
    boss.y = random_int(border_top.y + border_top.height, border_bottom.y - boss.height)
    bosss.push(boss)
  end

  Window.bgcolor = C_WHITE
  Window.loop do

    borders.each do |border|
      border.draw
    end

    bosss.each do |boss|
      boss.update
      boss.draw
    end

    Sprite.check(borders + bosss)
  end
end
