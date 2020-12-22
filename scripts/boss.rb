#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

require "dxruby"


class Boss < Sprite

  attr_accessor :shadow_x, :shadow_y, :name, :id, :is_drag, :mode, :is_reserved
  attr_reader :width, :height, :collision_ratios

  if __FILE__ == $0 then
    require "../lib/common"
    require "../lib/dxruby/images"
    IMAGE = "../images/boss_kingyo.PNG"
  else
    require "./lib/common"
    require "./lib/dxruby/images"
    IMAGE = "./images/boss_kingyo.PNG"
  end

  SHADOW_OFFSET_X = 5
  SHADOW_OFFSET_Y = 5

  ANIME_ADJUST_SPEED_RATIO = 0.05
  CATCHED_ANIME_SPEED_RATIO = 1.5

  BORDER_COLLISION_RATIOS_FOR_BOSS = [0.01, 0.2, 0.2, 0.01]

  include Common

  def initialize(x=0, y=0, width=100, height=100, angle=0, id=0,
                 speed_ranges={:wait=>[0, 1], :move=>[1, 3], :escape=>[1, 3]},
                 mode_ranges={:wait=>[0, 200], :move=>[0, 100], :escape=>[0, 200]}, name="boss", target=Window, is_drag=false)
    super()

    image0 = Image.load_tiles(IMAGE, 4, 1, true)
    image1 = image0.map { |image| image.flush([64, 0, 0, 0]) }
    image01s = [image0, image1]

    scale_x = width / image0[0].width.to_f if width
    scale_y = height / image0[0].height.to_f if height
    scale_x = scale_y unless width
    scale_y = scale_x unless height

    @images = []
    image01s.each do |image01|
      images = []
      image01.map do |image|
        images.push(Images.scale_resize(image, scale_x, scale_y))
      end
      @images.push(images)
    end

    self.x = x
    self.y = y
    self.image = @images[0][0]
    @shadow_image = @images[1][0]
    @width = self.image.width
    @height = self.image.height
    self.collision = [0, 0, @width, @height]
    self.target = target
    self.angle = angle

    @shadow_x = SHADOW_OFFSET_X
    @shadow_y = SHADOW_OFFSET_Y

    @id = id
    @name = name
    @is_drag = is_drag
    @mode_ranges = mode_ranges
    @speed_ranges = speed_ranges
    @anime_count = 0
    @collision_ratios = BORDER_COLLISION_RATIOS_FOR_BOSS

    modes = [:wait, :move]
    self.change_mode(modes[rand(2)])
  end

  def set_pos(x, y)
    self.x = x
    self.y = y
  end

  def update
    @anime_count += @speed * ANIME_ADJUST_SPEED_RATIO if @speed
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
      radian = (self.angle - 90) * (Math::PI / 180)
      self.x += Math.cos(radian) * @speed
      self.y += Math.sin(radian) * @speed
      @move_count += 1
    end
  end

  def escape

  end

  def catched
    @speed = @old_speed * CATCHED_ANIME_SPEED_RATIO if @speed == @old_speed
  end

  def hit(obj)

  end

  def draw
    self.target.draw_ex(self.x + @shadow_x, self.y + @shadow_y, @shadow_image, {:z=>self.z, :angle=>self.angle})
    self.target.draw_ex(self.x, self.y, self.image, {:z=>self.z, :angle=>self.angle})
  end
end


if __FILE__ == $0 then

  Window.width = 1920
  Window.height = 1080

  require "./border"
  include Common

  border = Border.new(50, 50, Window.width - 100, Window.height - 100)

  p Math.sqrt(Window.height * 0.009)

  bosss = []
  20.times do |index|
    boss_height = Window.height * rand_float(0.3, 0.6)
    boss = Boss.new(0, 0, nil, boss_height, rand(360), index,
                    {:wait=>[0, Math.sqrt(Window.height * 0.001)],
                     :move=>[Math.sqrt(Window.height * 0.001), Math.sqrt(Window.height * 0.009)],
                     :escape=>[Math.sqrt(Window.height * 0.001), Math.sqrt(Window.height * 0.009)]})
    boss.set_pos(random_int(border.x, border.x + border.width - boss.width),
                 random_int(border.y, border.y + border.height - boss.height))
    bosss.push(boss)
  end

  Window.bgcolor = C_WHITE
  Window.loop do

    border.draw

    bosss.each do |boss|
      boss.update
      boss.draw
    end
    Sprite.check(border.blocks + bosss)
  end
end
