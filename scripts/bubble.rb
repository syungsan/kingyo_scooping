#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

require "dxruby"


class Bubble < Sprite

  if __FILE__ == $0 then
    require "../lib/common"
    IMAGE = "../images/bubble_0.png"
  else
    require "./lib/common"
    IMAGE = "./images/bubble_0.png"
  end

  INIT_SCALE = 0.1
  INIT_AMPLITUDE = 0.5
  INIT_ANGULAR_VELOCITY = 0.5
  ALPHA = 128
  SIGNS = [-1, 1]

  attr_accessor :id, :name, :is_drag
  attr_reader :width, :height

  include Common

  def initialize(min_y=0, x_ranges=[0, 800], y_ranges=[600, 1200], scale_up_speed_ranges=[1.5, 6.0],
                 accel_ranges=[1, 5], amplification_speed_ranges=[1.5, 6.0], angular_velo_up_speed_ranges=[1.5, 6.0],
                 id=0, name="bubble", target=Window, is_drag=false)
    super()
    image = Image.load(IMAGE)
    self.image = image
    @width = self.image.width
    @height = self.image.height
    @min_y = min_y

    @x_ranges = x_ranges
    @y_ranges = y_ranges

    @scale_up_speed_ranges = scale_up_speed_ranges
    @accel_ranges = accel_ranges
    @amplification_speed_ranges = amplification_speed_ranges
    @angular_velo_up_speed_ranges = angular_velo_up_speed_ranges

    self.target = target
    self.alpha = ALPHA
    @id = id
    @name = name
    @is_drag = is_drag

    self.init
  end

  def set_x(x_ranges)
    @x_ranges = x_ranges
    self.x = self.rand_float(@x_ranges[0], @x_ranges[1]).to_i
  end

  def set_y(y_ranges)
    @y_ranges = y_ranges
    self.y = self.rand_float(@y_ranges[0], @y_ranges[1]).to_i
  end

  def init
    self.scale_x = INIT_SCALE
    self.scale_y= INIT_SCALE

    @scale_up_speed = self.rand_float(@scale_up_speed_ranges[0], @scale_up_speed_ranges[1])
    @accel = self.rand_float(@accel_ranges[0], @accel_ranges[1])
    @amplification_speed = self.rand_float(@amplification_speed_ranges[0], @amplification_speed_ranges[1])
    @angular_velo_up_speed = self.rand_float(@angular_velo_up_speed_ranges[0], @angular_velo_up_speed_ranges[1])

    @sign = SIGNS[rand(2)]
    @rise_count = 0
    @degree = 0
  end

  def update

    self.y -= @accel * @rise_count
    radian = (@degree) * (Math::PI / 180)
    self.x += INIT_AMPLITUDE * @amplification_speed * Math.sin(radian * INIT_ANGULAR_VELOCITY * @angular_velo_up_speed)
    @rise_count += 1
    @degree += 1

    self.scale_x *= @scale_up_speed
    self.scale_y *= @scale_up_speed

    if self.y < @min_y - self.height
      self.init
      self.set_x(@x_ranges)
      self.set_y(@y_ranges)
    end
  end

  def draw
    self.target.draw_ex(self.x, self.y, self.image,
                        {:scale_x=>self.scale_x, :scale_y=>self.scale_y, :alpha=>self.alpha})
  end
end


if __FILE__ == $0 then

  Window.width = 1920
  Window.height = 1080

  bubble_scale_up_speed_min = 1
  bubble_scale_up_speed_max = bubble_scale_up_speed_min * 1.004
  bubble_accel_min = 0.005
  bubble_accel_max = bubble_accel_min * 10
  bubble_amplification_speed_min = 1
  bubble_amplification_speed_max = bubble_amplification_speed_min * 10
  bubble_angular_velo_up_speed_min = 1
  bubble_angular_velo_up_speed_max = bubble_angular_velo_up_speed_min * 10

  bubbles = []
  700.times do
    bubble = Bubble.new(-1 * Window.height * 0.5, [0, 0], [0, 0],
                        [bubble_scale_up_speed_min, bubble_scale_up_speed_max],
                            [bubble_accel_min, bubble_accel_max],
                        [bubble_amplification_speed_min, bubble_amplification_speed_max],
                        [bubble_angular_velo_up_speed_min, bubble_angular_velo_up_speed_max])
    bubble.set_x([-1 * bubble.width * Math.sqrt(2), Window.width + (bubble.width * Math.sqrt(2))])
    bubble.set_y([Window.height + bubble.height, Window.height * 1.1])
    bubbles.push(bubble)
  end

  Window.bgcolor = [255, 240, 245]
  Window.loop do
    bubbles.each do |bubble|
      bubble.update
      bubble.draw
    end
  end
end
