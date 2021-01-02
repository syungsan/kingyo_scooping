#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

require "dxruby"


class Weed < Sprite

  attr_accessor :shadow_x, :shadow_y, :name, :id, :is_drag, :is_reserved,
                :angle_candidate, :direction_of_rotation
  attr_reader :width, :height, :collision_ratios, :mode, :pre_mode

  if __FILE__ == $0 then
    require "../lib/dxruby/images"
    require "../lib/common"
    IMAGE = "../images/kingyomo001.png"
  else
    require "./lib/dxruby/images"
    require "./lib/common"
    IMAGE = "./images/kingyomo001.png"
  end

  include Common

  SHADOW_OFFSET_X = 5
  SHADOW_OFFSET_Y = 5

  BORDER_COLLISION_RATIOS = [0.01, 0.3, 0.3, 0.01]

  SIGNS = {:right=>1, :left=>-1}
  ESCAPE_ROATATION_SPEED_RATIO = 0.1

  def initialize(x=0, y=0, width=100, height=100, angle=0, id=0, speed_ranges={:escape=>[1, 3]}, mode_ranges={:escape=>[0, 200]},
                 escape_change_timing = 0.3, name="weed", target=Window, is_drag=false)
    super()

    image = Image.load(IMAGE)
    shadow = image.flush([64, 0, 0, 0])
    images = [image, shadow]

    scale_x = width / image.width.to_f if width
    scale_y = height / image.height.to_f if height
    scale_x = scale_y unless width
    scale_y = scale_x unless height

    @images = []
    images.each do |image|
      @images.push(Images.scale_resize(image, scale_x, scale_y))
    end

    self.x = x
    self.y = y
    self.image = @images[0]
    @width = self.image.width
    @height = self.image.height
    self.collision = [0, 0, @width, @height]
    self.target = target
    self.angle = angle

    @id = id
    @name = name
    @is_drag = is_drag

    @shadow_x = SHADOW_OFFSET_X
    @shadow_y = SHADOW_OFFSET_Y

    @mode_ranges = mode_ranges
    @speed_ranges = speed_ranges

    @collision_ratios = BORDER_COLLISION_RATIOS

    @escape_count = 0
    @escape_length = 0
    @escape_cahange_timing = escape_change_timing
    @speed = rand_float(@speed_ranges[:escape][0], @speed_ranges[:escape][1])
    @speed *= (1 / @height.to_f)

    self.change_mode(:wait)
  end

  def set_pos(x, y)
    self.x = x
    self.y = y
  end

  def update

    case @mode

    when :wait, :broke

    when :reserved
      @mode = :wait

    when :escape
      self.escape
    end
  end

  def change_mode(mode)

    case mode

    when :wait, :broke

    when :escape

      if @escape_count > @escape_length * @escape_cahange_timing then
        @escape_count = 0

        @escape_length = random_int(@mode_ranges[:escape][0], @mode_ranges[:escape][1])
        @speed = rand_float(@speed_ranges[:escape][0], @speed_ranges[:escape][1])
        @speed *= (1 / @height.to_f)
      end

    when :catched
      @pre_mode = @mode
    end
    @mode = mode
  end

  def escape

    if @escape_count > @escape_length then
      self.change_mode(:wait)
    else
      radian = (@angle_candidate - 90) * (Math::PI / 180)
      self.x += Math.cos(radian) * @speed
      self.y += Math.sin(radian) * @speed
      self.angle += SIGNS[@direction_of_rotation] * @speed * ESCAPE_ROATATION_SPEED_RATIO
      @escape_count += 1
    end
  end

  def hit(obj)

  end

  def draw
    self.target.draw_ex(self.x + @shadow_x, self.y + @shadow_y, @images[1], {:z=>self.z, :angle=>self.angle})
    self.target.draw_ex(self.x, self.y, self.image, {:z=>self.z, :angle=>self.angle})
  end
end


if __FILE__ == $0 then

  require "../lib/common"
  include Common

  Window.width = 1280
  Window.height = 720

  weeds = []
  30.times do
    weed_height = Window.height * rand_float(0.2, 0.5)
    weed = Weed.new(0, 0, nil, weed_height, rand(360))
    weed.set_pos(random_int(0, Window.width - weed.width), random_int(0, Window.height - weed.height))
    weeds.push(weed)
  end

  Window.loop do
    weeds.each do |weed|
      weed.draw
    end
  end
end
