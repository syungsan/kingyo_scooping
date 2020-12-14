#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

require "dxruby"


class Alert

  attr_accessor :mode, :z
  attr_reader :id, :name

  BASE_HEIGHT_RATIO = 0.2
  BASE_COLOR = C_YELLOW
  BASE_ALPHA = 128
  SUB_ALERT_HEIGHT_SIZE_RATIO = 0.8
  SUB_ALERT_WEIGHT= 500
  SUB_ALERT_IS_ITALIC = false
  SUB_ALERT_COLOR = [77, 0, 153]
  SUB_ALERT_IS_SHADOW = true
  SUB_ALERT_SHADOW_OFF_SET_X = 3
  SUB_ALERT_SHADOW_OFF_SET_Y = 3
  SHADOW_COLOR = [64, 64, 64]
  MAIN_ALERT_HEIGHT_SIZE_RATIO = 0.8
  MAIN_ALERT_WEIGHT = 300
  MAIN_ALERT_IS_ITALIC = false
  MAIN_ALERT_COLOR = C_RED
  MAIN_ALERT_IS_SHADOW = true
  MAIN_ALERT_SHADOW_OFF_SET_X = 5
  MAIN_ALERT_SHADOW_OFF_SET_Y = 5
  SUB_ALERT_MAX_NUMBER = 5
  SUB_ALERT_INTERVAL_RATIO = 2.0
  MAIN_ALERT_SPEED = -10
  SUB_ALERT_SPEED = 10

  class AlertFont < Sprite

    attr_accessor :is_drag, :name, :id
    attr_reader :width, :height

    def initialize(x, y, size, string, font_type, option={})
      option = {:weight=>300, :italic=>false, :color=>C_WHITE, :shadow=>true, :shadow_x=>3, :shadow_y=>3, :shadow_color=>[64, 64, 64], :id=>0, :is_drag=>false, :target=>Window}.merge(option)
      super()
      font = Font.new(size, font_type, {:weight=>option[:waight], :italic=>option[:italic]})
      image = Image.new(font.get_width(string), size)
      image.draw_font_ex(0, 0, string, font, {:color=>option[:color], :shadow=>option[:shadow], :shadow_x=>option[:shadow_x], :shadow_y=>option[:shadow_y], :shadow_color=>option[:shadow_color]})
      font.dispose
      self.x = x
      self.y = y
      self.image = image
      self.target = option[:target]
      @width = self.image.width
      @height = self.image.height
      @id = option[:id]
      @name = "alert_font"
      @is_drag = option[:is_drag]
    end

    def draw
      self.target.draw_ex(self.x, self.y, self.image, {:z=>self.z})
    end
  end

  def initialize(x, y, width, height, z=0, id=0, target=Window)
    @name = "alert"
    @id = id
    @x = x
    @y = y
    @z = z
    @target = target
    @width = width
    @height= height
    @mode = :wait
    self.make_base
  end

  def make_base
    @base_image = Image.new(@width, @height * BASE_HEIGHT_RATIO)
    @base_image.box_fill(0, 0, @base_image.width, @base_image.height, BASE_COLOR)
  end

  def make_sub_alert(string, font_type, id=0, is_drag=false, target=Window)
    size = @height * BASE_HEIGHT_RATIO * SUB_ALERT_HEIGHT_SIZE_RATIO
    option = {:weight=>SUB_ALERT_WEIGHT, :italic=>SUB_ALERT_IS_ITALIC, :color=>SUB_ALERT_COLOR, :shadow=>SUB_ALERT_IS_SHADOW, :shadow_x=>SUB_ALERT_SHADOW_OFF_SET_X, :shadow_y=>SUB_ALERT_SHADOW_OFF_SET_Y, :shadow_color=>SHADOW_COLOR, :id=>id, :is_drag=>is_drag, :target=>target}
    @sub_alert = AlertFont.new(0, 0, size, string, font_type, option)
    @sub_alert.z = @z + 1
    up_sub_alerts = []
    SUB_ALERT_MAX_NUMBER.times do |index|
      up_sub_alert = AlertFont.new(0, @y + (@height * BASE_HEIGHT_RATIO - size) * 0.5, size, string, font_type, option)
      up_sub_alert.x = @x - (up_sub_alert.width * SUB_ALERT_INTERVAL_RATIO * index)
      up_sub_alert.z = @z + 1
      up_sub_alert.name = "up_sub_alert"
      up_sub_alerts.push(up_sub_alert)
    end
    down_sub_alerts = []
    SUB_ALERT_MAX_NUMBER.times do |index|
      down_sub_alert = AlertFont.new(0, @y + @height - (@height * BASE_HEIGHT_RATIO) + ((@height * BASE_HEIGHT_RATIO - size) * 0.5) , size, string, font_type, option)
      down_sub_alert.x = @x - (down_sub_alert.width * SUB_ALERT_INTERVAL_RATIO * (0.5 + index))
      down_sub_alert.z = @z + 1
      down_sub_alert.name = "down_sub_alert"
      down_sub_alerts.push(down_sub_alert)
    end
    @sub_alerts = up_sub_alerts + down_sub_alerts
  end

  def make_main_alert(string, font_type, id=0, is_drag=false, target=Window)
    size = @height * (1 - (BASE_HEIGHT_RATIO * SUB_ALERT_HEIGHT_SIZE_RATIO * 2)) * MAIN_ALERT_HEIGHT_SIZE_RATIO
    option = {:weight=>MAIN_ALERT_WEIGHT, :italic=>MAIN_ALERT_IS_ITALIC, :color=>MAIN_ALERT_COLOR, :shadow=>MAIN_ALERT_IS_SHADOW, :shadow_x=>MAIN_ALERT_SHADOW_OFF_SET_X, :shadow_y=>MAIN_ALERT_SHADOW_OFF_SET_Y, :shadow_color=>SHADOW_COLOR, :id=>id, :is_drag=>is_drag, :target=>target}
    @main_alert = AlertFont.new(@x + @width, 0, size, string, font_type, option)
    @main_alert.y = @y + ((@height - @main_alert.height) * 0.5)
    @main_alert.z = @z
  end

  def update
    if @mode == :run then
      @main_alert.x += MAIN_ALERT_SPEED if @main_alert.x >= @x - (@main_alert.width)
      @sub_alerts.each do |sub_alert|
        if sub_alert.x <= @x + @width then
          sub_alert.x += SUB_ALERT_SPEED
        end
      end
      if @main_alert.x < @x - (@main_alert.width) and @sub_alerts.select { |obj| obj.x <= @x + @width}.empty?
        @main_alert.x = @x + @width
        up_sub_alerts = @sub_alerts.select { |obj| obj.name == "up_sub_alert"}
        up_sub_alerts.each_with_index do |up_sub_alert, index|
          up_sub_alert.x = @x - (up_sub_alert.width * SUB_ALERT_INTERVAL_RATIO * index)
        end
        down_sub_alerts = @sub_alerts.select { |obj| obj.name == "down_sub_alert"}
        down_sub_alerts.each_with_index do |down_sub_alert, index|
          down_sub_alert.x = @x - (down_sub_alert.width * SUB_ALERT_INTERVAL_RATIO * (0.5 + index))
        end
        @mode = :finish
      end
    end
  end

  def draw
    @target.draw_alpha(@x, @y, @base_image, BASE_ALPHA, @z)
    @target.draw_alpha(@x, @y + @height - @base_image.height, @base_image, BASE_ALPHA, @z)
    @sub_alerts.each do |sub_alert|
      sub_alert.draw
    end
    @main_alert.draw
  end
end


if __FILE__ == $0 then

  CHECK_POINT_FONT = "../fonts/CP Font.ttf"
  Font.install(CHECK_POINT_FONT)
  CHECK_POINT_FONT_TYPE = "チェックポイントフォント"

  LIGHT_NOVEL_POP_FONT = "../fonts/ラノベPOP.otf"
  Font.install(LIGHT_NOVEL_POP_FONT)
  LIGHT_NOVEL_POP_FONT_TYPE = "07ラノベPOP"

  Window.width = 1280
  Window.height = 720

  alert = Alert.new(0, 0, Window.width, Window.height)
  alert.make_sub_alert("WARNING!", LIGHT_NOVEL_POP_FONT_TYPE)
  alert.make_main_alert("警告！ ボス金魚出現！", CHECK_POINT_FONT_TYPE)
  alert.mode = :run

  Window.bgcolor = C_CYAN
  Window.loop do
    alert.update if alert.mode == :run
    alert.draw if alert.mode == :run
  end
end
