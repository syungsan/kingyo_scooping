#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

require "dxruby"


class LifeGauge

  attr_accessor :shadow_x, :shadow_y, :name, :id, :target, :has_out_of_life, :z
  attr_reader :width, :height

  SHADOW_OFFSET_X = 5
  SHADOW_OFFSET_Y = 5
  SPEED_UNIT = 1.0
  DEFAULT_COLOR = C_GREEN
  ALERT_COLOR = C_RED

  if __FILE__ == $0 then
    require "../lib/dxruby/roundbox"
  else
    require "./lib/dxruby/roundbox"
  end

  def initialize(width=10, height=100, border_color=C_BLUE, border_thickness=1, round_radius=5, name="life_gauge", id=0, target=Window)

    @image = Image.new(width, height)
    @width = @image.width
    @height = @image.height

    @color = DEFAULT_COLOR
    @border_color = border_color
    @border_thickness = border_thickness
    @round_radius = round_radius
    @name = name
    @id = 0
    @target = target

    @x = 0
    @y = 0
    @z = 0

    @mode = :wait
    @change_count = 0
    @current_width = @width
    @points = []
    @has_out_of_life = false

    @shadow_x = SHADOW_OFFSET_X
    @shadow_y = SHADOW_OFFSET_Y

    self.change_gauge(@current_width)
  end

  def set_pos(x, y)
    @x = x
    @y = y
  end

  def change_life(point)
    @points.push(point)
    @mode = :change
  end

  def change_gauge(change_width)
    @image.clear
    if change_width <= @width * 30 / 100.to_f then
      @color = ALERT_COLOR
    else
      @color = DEFAULT_COLOR
    end

    @image.roundbox_fill(@width - change_width, 0, @width, @height, @round_radius, @border_color)
    @image.roundbox_fill(@width - change_width + @border_thickness, @border_thickness, @width - (@border_thickness * 2),
                         @height - (@border_thickness * 2), @round_radius, @color)
    @shadow = @image.flush([64, 0, 0, 0])
  end

  def update

    if @mode == :change then
      unless @points.empty? then

        diff = @points[0] * SPEED_UNIT * @change_count
        if diff >= @points[0] then
          @change_width = @current_width + (@width * diff / 100)
          if @change_width <= 0 then
            @has_out_of_life = true unless @has_out_of_life
            @change_width += @width
          end
          self.change_gauge(@change_width)
          @change_count += 1
        else
          @current_width = @change_width
          @points.shift(1)
          @has_out_of_life = false
          @change_count = 0
        end
      else
        @mode = :wait
      end
    end
  end

  def draw
    @target.draw(@x + @shadow_x, @y + @shadow_y, @shadow, @z - 1) if @shadow
    @target.draw(@x, @y, @image, @z) if @image
  end

  def vanish
    @shadow.dispose
    @image.dispose
  end
end


class PoiGage

  attr_accessor :shadow_x, :shadow_y, :name, :id, :z
  attr_reader :width, :height

  SHADOW_OFFSET_X = 5
  SHADOW_OFFSET_Y = 5

  if __FILE__ == $0 then
    require "../lib/dxruby/images"
    MINI_POI_IMAGE = "../images/mini_poi.png"
  else
    require "./lib/dxruby/images"
    MINI_POI_IMAGE = "./images/mini_poi.png"
  end

  def initialize(width=100, height=100, name="poi_gauge", id=0, target=Window)

    image = Image.load(MINI_POI_IMAGE)

    scale_x = width / image.width.to_f if width
    scale_y = height / image.height.to_f if height
    scale_x = scale_y unless width
    scale_y = scale_x unless height

    @image = Images.scale_resize(image, scale_x, scale_y)
    @shadow = @image.flush([64, 0, 0, 0])

    @width = @image.width
    @height = @image.height
    @name = name
    @id = 0
    @target = target

    @x = 0
    @y = 0
    @z = 0

    @shadow_x = SHADOW_OFFSET_X
    @shadow_y = SHADOW_OFFSET_Y
  end

  def set_pos(x, y)
    @x = x
    @y = y
  end

  def draw
    @target.draw(@x + @shadow_x, @y + @shadow_y, @shadow, @z - 1) if @shadow
    @target.draw(@x, @y, @image, @z) if @image
  end

  def vanish
    @shadow.dispose
    @image.dispose
  end
end


if __FILE__ == $0 then

  Window.width = 1280
  Window.height = 720

  life_gauge_width = Window.width * 0.75
  life_gauge_height = Window.height * 0.02

  life_gauge = LifeGauge.new(life_gauge_width, life_gauge_height)
  life_gauge.set_pos((Window.width - life_gauge.width) * 0.2, (Window.height - life_gauge.height) * 0.95)

  poi_gauge_relative_size = Window.height * 0.1
  poi_gauge_interval = Window.width * 0.023
  poi_gauges = []

  5.times do |index|
    poi_gauge = PoiGage.new(nil, poi_gauge_relative_size)
    poi_gauge.set_pos((Window.width - poi_gauge.width) * 0.85 + (poi_gauge_interval * index), (Window.height - poi_gauge.height) * 0.96)
    poi_gauges.push(poi_gauge)
  end
  poi_gauges.reverse!

  count = 0
  continueble = false

  Window.bgcolor = C_WHITE
  Window.loop do

    life_gauge.draw
    life_gauge.update
    life_gauge.change_life(-20) if count == 0
    life_gauge.change_life(-50) if count == 30
    life_gauge.change_life(-50) if count == 90
    life_gauge.change_life(-30) if count == 120
    life_gauge.change_life(-10) if count == 150
    count += 1

    if life_gauge.has_out_of_life and not continueble then
      p "命が尽きた…けど復活した！"
      poi_gauges[-1].vanish
      poi_gauges.delete_at(-1)
      continueble = true
    end

    poi_gauges.each do |poi_gauge|
      poi_gauge.draw
    end
  end
end
