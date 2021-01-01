#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

require "dxruby"


class Kingyo < Sprite

  attr_accessor :shadow_x, :shadow_y, :name, :id, :is_drag, :is_reserved, :angle_candidate
  attr_reader :width, :height, :collision_ratios, :kind_of, :mode, :pre_mode

  if __FILE__ == $0 then
    require "../lib/common"
    require "../lib/dxruby/images"
    require "../lib/weighted_randomizer"
    require "../lib/dxruby/easing"
    IMAGES = ["../images/kingyo03.png", "../images/demekin_black.png"]
  else
    require "./lib/common"
    require "./lib/dxruby/images"
    require "./lib/weighted_randomizer"
    require "./lib/dxruby/easing"
    IMAGES = ["./images/kingyo03.png", "./images/demekin_black.png"]
  end

  include Common
  include Easing

  KIND_OF = [:red, :black]

  ANIME_ADJUST_SPEED_RATIO = 0.1
  CATCHED_ANIME_SPEED_RATIO = 1.5

  SHADOW_OFFSET_X = 5
  SHADOW_OFFSET_Y = 5

  BORDER_COLLISION_RATIOS_FOR_RED_KINGYO = [0.01, 0.3, 0.3, 0.01]
  BORDER_COLLISION_RATIOS_FOR_BLACK_KINGYO = [0.08, 0.3, 0.3, 0.08]

  def initialize(x=0, y=0, width=100, height=100, kind_of=:red, angle=0, id=0,
                 speed_ranges={:wait=>[0, 1], :move=>[1, 5], :escape=>[1, 5]},
                 mode_ranges={:wait=>[0, 100], :move=>[0, 100], :escape=>[0, 100]},
                 personality_weights = {:escape=>80, :ignore=>50, :against=>20},
                 escape_change_timing = 0.2,
                 target=Window, is_drag=false)
    super()

    @images = []
    IMAGES.each do |image|
      image0 = Image.load_tiles(image, 4, 1, true)
      image1 = image0.map { |image| image.flush([64, 0, 0, 0]) }
      images = [image0, image1]
      @images.push(images)
    end

    @kind_of = kind_of

    scale_x = width / @images[KIND_OF.index(@kind_of)][0][0].width.to_f if width
    scale_y = height / @images[KIND_OF.index(@kind_of)][0][0].height.to_f if height
    scale_x = scale_y unless width
    scale_y = scale_x unless height

    @images[KIND_OF.index(@kind_of)].size.times do |index|
      @images[KIND_OF.index(@kind_of)][index].map do |image|
        @images[KIND_OF.index(@kind_of)][index][@images[KIND_OF.index(@kind_of)][index].index(image)] =
          Images.scale_resize(image, scale_x, scale_y)
      end
    end

    @collision_ratios = BORDER_COLLISION_RATIOS_FOR_RED_KINGYO if @kind_of == :red
    @collision_ratios = BORDER_COLLISION_RATIOS_FOR_BLACK_KINGYO if @kind_of == :black

    self.x = x
    self.y = y
    self.image = @images[KIND_OF.index(@kind_of)][0][0]
    @shadow_image = @images[KIND_OF.index(@kind_of)][1][0]
    @width = self.image.width
    @height = self.image.height
    self.collision = [0, 0, @width, @height]
    self.target = target
    self.angle = angle

    @shadow_x = SHADOW_OFFSET_X
    @shadow_y = SHADOW_OFFSET_Y

    @id = id
    @name = "#{kind_of.to_s}_kingyo"
    @is_drag = is_drag
    @mode_ranges = mode_ranges
    @speed_ranges = speed_ranges
    @anime_count = 0

    @escape_count = 0
    @escape_length = 0
    @personal_w_ran = WeightedRandomizer.new(personality_weights)
    @escape_cahange_timing = escape_change_timing

    modes = [:wait, :move]
    self.change_mode(modes[rand(2)])
  end

  def set_pos(x, y)
    self.x = x
    self.y = y
  end

  def update

    @anime_count += @speed * ANIME_ADJUST_SPEED_RATIO if @speed
    @anime_count = 0 if @anime_count > @images[KIND_OF.index(@kind_of)][0].size
    self.image = @images[KIND_OF.index(@kind_of)][0][@anime_count.floor]
    @shadow_image = @images[KIND_OF.index(@kind_of)][1][@anime_count.floor]

    case @mode
    when :wait
      self.wait

    when :move
      self.move

    when :escape
      self.escape

    when :catched
      self.catched

    when :reserved, :ignore
      modes = [:wait, :move]
      self.change_mode(modes[rand(2)])
    end
  end

  def change_mode(mode)

    @wait_count = 0
    @move_count = 0
    @move_time = 0

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

    when :escape

      @escape_count = 0 if @escape_count > @escape_length * @escape_cahange_timing

      if @escape_count == 0 then
        personality = @personal_w_ran.sample
        @angle_candidate = @angle_candidate + 180 if personality == :against

        if personality == :escape or personality == :against then
          self.angle = @angle_candidate
          @escape_length = random_int(@mode_ranges[:escape][0], @mode_ranges[:escape][1])
          @speed = rand_float(@speed_ranges[:escape][0], @speed_ranges[:escape][1])
          @old_speed = @speed
        else
          mode = :ignore
        end
      end

    when :catched
      @pre_mode = @mode
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

    if @move_count >= @move_length then
      self.change_mode(:wait)
    else
      half_length = @move_length / 2
      radian = (self.angle - 90) * (Math::PI / 180)

      if @move_count < half_length.round then
        in_speed = ease_in_out_quad(@move_time, 0, @old_speed, half_length.round * 0.01)
        if not in_speed.nan? then
          self.x += Math.cos(radian) * in_speed
          self.y += Math.sin(radian) * in_speed
          @speed = in_speed
          @move_time += 0.01
        end

      elsif @move_count == half_length.round then
        @move_time = 0
        @move_count += 1

      elsif @move_count > half_length.round then
        out_speed = ease_in_out_quad(@move_time, @old_speed, -1 * @old_speed, half_length.round * 0.01)
        if not out_speed.nan? then
          self.x += Math.cos(radian) * out_speed
          self.y += Math.sin(radian) * out_speed
          @speed = out_speed
          @move_time += 0.01
        end
      end
      @move_count += 1
    end
  end

  def escape

    if @escape_count > @escape_length then
      modes = [:wait, :move]
      self.change_mode(modes[rand(2)])
    else
      radian = (self.angle - 90) * (Math::PI / 180)
      self.x += Math.cos(radian) * @speed
      self.y += Math.sin(radian) * @speed
      @escape_count += 1
    end
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

  Window.width = 1280
  Window.height = 720

  require "./border"
  include Common

  border = Border.new(50, 50, Window.width - 100, Window.height - 100)

  KIND_OF = [:red, :black]

  kingyos = []
  20.times do |index|
    kingyo_height = Window.height * rand_float(0.1, 0.2)
    kingyo = Kingyo.new(0, 0, nil, kingyo_height, KIND_OF[rand(2)], rand(360), index,
                        {:wait=>[0, Math.sqrt(Window.height * 0.001)],
                         :move=>[Math.sqrt(Window.height * 0.001), Math.sqrt(Window.height * 0.024)],
                         :escape=>[Math.sqrt(Window.height * 0.003), Math.sqrt(Window.height * 0.072)]})
    kingyo.set_pos(kingyo.x = random_int(border.x, border.x + border.width - kingyo.width),
                   kingyo.y = random_int(border.y, border.y + border.height - kingyo.height))
    kingyos.push(kingyo)
  end

  Window.bgcolor = C_WHITE
  Window.loop do

    border.draw

    kingyos.each do |kingyo|
      kingyo.update
      kingyo.draw
    end

    Sprite.check(border.blocks + kingyos)
  end
end