#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

require "dxruby"


class Illust < Sprite

  attr_accessor :id, :name, :is_drag, :mode
  attr_reader :width, :height, :illust_number

  if __FILE__ == $0 then
    require "../lib/dxruby/images"
    require "../lib/common"
    ILLUSTS =  Dir.glob("../images/illust_*.png")
    CRUSHED_IMAGE = "../images/splash-clip-art.png"
  else
    require "./lib/dxruby/images"
    require "./lib/common"
    ILLUSTS =  Dir.glob("./images/illust_*.png")
    CRUSHED_IMAGE = "./images/splash-clip-art.png"
  end

  include Common

  HEAD_THETA_RANGE = 60
  SIGN = [-1, 1]
  IN_MARGIN_RATIO = 0.5
  OUT_MARGIN_RATIO = 0.8

  MAX_CRUSH_COUNT = 60

  def initialize(illust_number, height_size, bound_rect, attack_target=nil, speed_ranges=[2.0, 5.0],
                 rotation_speed_ranges=[1, 4], name="illust", id=0, target=Window, is_drag=false)
    super()

    @illust_number = illust_number
    image_src = Image.load(ILLUSTS[@illust_number])
    scale_y = height_size / image_src.height.to_f
    scale_x = scale_y
    crush_image_src = Image.load(CRUSHED_IMAGE)

    image = Images.scale_resize(image_src, scale_x, scale_y)
    crush_image = Images.scale_resize(crush_image_src, scale_x * 2, scale_y * 2)
    @images = [image, crush_image]

    self.image = @images[0]
    @width = self.image.width
    @height = self.image.height
    @speed_ranges = speed_ranges
    @rotation_speed_ranges = rotation_speed_ranges

    @name = name
    @id = id
    self.target = target
    @is_drag = is_drag

    @attack_target = attack_target

    @bound_rect = bound_rect
    @init_bounds = [[[@bound_rect[0], @bound_rect[0] + @bound_rect[2] - @height], @bound_rect[1] - @height],
               [@bound_rect[0] - @height, [@bound_rect[1], @bound_rect[1] + @bound_rect[3] - @height]],
               [@bound_rect[0] + @bound_rect[2], [@bound_rect[1], @bound_rect[1] + @bound_rect[3] - @height]],
               [[@bound_rect[0], @bound_rect[0] + @bound_rect[2] - @height], @bound_rect[1] + @bound_rect[3]]]

    self.constract

    @crush_count = 0
    self.change_mode(:normal)
  end

  def set_pos(x, y)
    self.x = x
    self.y = y
  end

  def change_mode(mode)

    case mode

    when :normal

    when :crushed
      self.image = @images[1]
    end
    @mode = mode
  end

  def constract

    bound_direction = rand(4)
    margin = @height * IN_MARGIN_RATIO

    case bound_direction

    when 0
      x = random_int(@init_bounds[bound_direction][0][0], @init_bounds[bound_direction][0][1])
      y = @init_bounds[bound_direction][1] - margin
      @direction = random_int(90 - (HEAD_THETA_RANGE * 0.5), 90 + (HEAD_THETA_RANGE * 0.5))

    when 1
      x = @init_bounds[bound_direction][0] - margin
      y = random_int(@init_bounds[bound_direction][1][0], @init_bounds[bound_direction][1][1])
      @direction = random_int(-1 * HEAD_THETA_RANGE * 0.5, HEAD_THETA_RANGE * 0.5)

    when 2
      x = @init_bounds[bound_direction][0] + margin
      y = random_int(@init_bounds[bound_direction][1][0], @init_bounds[bound_direction][1][1])
      @direction = random_int(180 - (HEAD_THETA_RANGE * 0.5), 180 + (HEAD_THETA_RANGE * 0.5))

    when 3
      x = random_int(@init_bounds[bound_direction][0][0], @init_bounds[bound_direction][0][1])
      y = @init_bounds[bound_direction][1] + margin
      @direction = random_int(270 - (HEAD_THETA_RANGE * 0.5), 270 + (HEAD_THETA_RANGE * 0.5))
    end
    self.set_pos(x, y)

    @speed = rand_float(@speed_ranges[0], @speed_ranges[1])
    @rotation_speed = SIGN[rand(2)] * random_int(@rotation_speed_ranges[0], @rotation_speed_ranges[1])

    self.change_mode(:normal)
  end

  def update

    if @mode == :normal then
      radian = @direction * (Math::PI / 180)
      self.x += Math.cos(radian) * @speed
      self.y += Math.sin(radian) * @speed
      self.angle += @rotation_speed

      margin = @height * OUT_MARGIN_RATIO
      if self.x < @bound_rect[0] - @height - margin or self.x > @bound_rect[0] + @bound_rect[2] + margin or
        self.y < @bound_rect[1] - @height - margin or self.y > @bound_rect[1] + @bound_rect[3] + margin then
        self.constract
      end

    elsif @mode == :crushed then
      if @crush_count >= MAX_CRUSH_COUNT then
        @crush_count = 0

        self.constract
        self.alpha = 255
        self.image = @images[0]
      else
        self.alpha = 255 - ((255 / MAX_CRUSH_COUNT) * @crush_count)
        @crush_count += 1
      end
    end
  end

  def hit(obj)
    if obj == @attack_target and not @mode == :crushed then
      self.change_mode(:crushed)
    end
  end

  def draw
    self.target.draw_ex(self.x, self.y, self.image, {:scale_x=>self.scale_x, :scale_y=>self.scale_y, :center_x=>nil, :center_y=>nil,
                                                     :alpha=>self.alpha, :blend=>:alpha, :color=>[255, 255, 255], :angle=>self.angle, :z=>self.z})
  end
end


if __FILE__ == $0 then

  Window.width = 1280
  Window.height = 720

  relative_scales = [0.2, 0.15, 0.2, 0.25, 0.45, 0.27]

  illusts = []
  12.times do
    illust_number = rand(6)
    relative_size = Window.height * relative_scales[illust_number]
    illust = Illust.new(illust_number, relative_size, [0, 0, Window.width, Window.height])
    illusts.push(illust)
  end

  Window.loop do
    illusts.each do |illust|
      illust.draw
      illust.update
    end
  end
end
