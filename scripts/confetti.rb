#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

require "dxruby"


class Confetti < Sprite

  CONFETTI_ALPHA = 128
  SIGN = [-1, 1]

  attr_accessor :id, :name, :is_drag
  attr_reader :width, :height

  def initialize(max_y=0, x_ranges=[0, 800], y_ranges=[0, 300], size_ranges=[1, 5], accel_ranges=[1, 5], amp_ranges=[1, 5], rot_speed_ranges=[1, 5],
                 angular_velo_ranges=[1, 5], id=0, target=Window, is_drag=false)
    super()
    @max_y = max_y
    @x_ranges = x_ranges
    @y_ranges = y_ranges
    @size_ranges = size_ranges
    @accel_ranges = accel_ranges
    @amp_ranges = amp_ranges
    @rot_speed_ranges = rot_speed_ranges
    @angular_velo_ranges = angular_velo_ranges
    self.target = target
    self.alpha = CONFETTI_ALPHA
    @id = id
    @name = "confetti"
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
    size = self.rand_float(@size_ranges[0], @size_ranges[1])
    color = [rand(256), rand(256), rand(256)]
    image = Image.new(size, size).box_fill(0, 0, size, size, color)
    self.image = image
    @width = self.image.width
    @height = self.image.height
    @accel = self.rand_float(@accel_ranges[0], @accel_ranges[1])
    @amp = self.rand_float(@amp_ranges[0], @amp_ranges[1])
    @rot_speed = self.rand_float(@rot_speed_ranges[0], @rot_speed_ranges[1])
    @angular_velo = self.rand_float(@angular_velo_ranges[0], @angular_velo_ranges[1])
    self.angle = rand(360)
    @sign = SIGN[rand(2)]
    @fall_count = 0
    @degree = 0
  end

  def update
    self.angle += @sign * @rot_speed
    self.y += @accel * @fall_count
    radian = (@degree) * (Math::PI / 180)
    self.x += @amp * Math.sin(radian * @angular_velo)
    @fall_count += 1
    @degree += 1
    if self.y > @max_y
      self.image.dispose if not self.image.disposed?
      self.init
      self.set_x(@x_ranges)
      self.set_y(@y_ranges)
    end
  end

  def draw
    self.target.draw_ex(self.x, self.y, self.image, {:angle=>self.angle, :alpha=>self.alpha}) if not self.image.disposed?
  end

  def rand_float(min, max)
    return rand() * (max - min) + min
  end
end


if __FILE__ == $0 then

  Window.width = 1280
  Window.height = 720

  confetti_size_min = Window.height * 0.03
  confetti_size_max = confetti_size_min * 3
  confetti_accel_min = 0.02
  confetti_accel_max = confetti_accel_min * 4
  confetti_amp_min = Window.height * 0.005
  confetti_amp_max = confetti_amp_min * 2
  confetti_rot_speed_min = 0.5
  confetti_rot_speed_max = confetti_rot_speed_min * 15
  confetti_angular_velo_min = 0.5
  confetti_angular_velo_max = confetti_angular_velo_min * 10

  confettis = []
  600.times do
    confetti = Confetti.new(Window.height, [0, 800], [0, 300], [confetti_size_min, confetti_size_max],
                            [confetti_accel_min, confetti_accel_max], [confetti_amp_min, confetti_amp_max],
                            [confetti_rot_speed_min, confetti_rot_speed_max], [confetti_angular_velo_min, confetti_angular_velo_max])
    confetti.set_x([-1 * confetti.width * Math.sqrt(2), Window.width + (confetti.width * Math.sqrt(2))])
    confetti.set_y([-1 * confetti.width * Math.sqrt(2), -2 * (Window.width + (confetti.width * Math.sqrt(2)))])
    confettis.push(confetti)
  end

  Window.bgcolor = [255, 240, 245]
  Window.loop do
    confettis.each do |confetti|
      confetti.update
      confetti.draw
    end
  end
end
