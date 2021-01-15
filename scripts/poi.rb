#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

require "dxruby"


class Poi <Sprite

  attr_accessor :shadow_x, :shadow_y, :name, :id, :is_drag, :mode, :old_pos, :is_impact, :impact_gain
  attr_reader :width, :height, :impact_radius

  require "rubygems"
  require "bigdecimal"

  if __FILE__ == $0 then
    require "../lib/dxruby/images"
    require "../lib/dxruby/easing"
    FRAME_IMAGE = "../images/poi_frame.png"
    PAPER_NORMAL_IMAGE = "../images/poi_paper_0.png"
    PAPER_BREAK_IMAGE = "../images/poi_paper_1.png"
    FLASH_IMAGE = "../images/poi_flash.png"
    BREAK_FLASH_IMAGE = "../images/poi_break_flash.png"
    DAMAGE_SOUND = "../sounds/nc46901.wav"
  else
    require "./lib/dxruby/images"
    require "./lib/dxruby/easing"
    FRAME_IMAGE = "./images/poi_frame.png"
    PAPER_NORMAL_IMAGE = "./images/poi_paper_0.png"
    PAPER_BREAK_IMAGE = "./images/poi_paper_1.png"
    FLASH_IMAGE = "./images/poi_flash.png"
    BREAK_FLASH_IMAGE = "./images/poi_break_flash.png"
    DAMAGE_SOUND = "./sounds/nc46901.wav"
  end

  include Easing

  SHADOW_OFFSET_X = 5
  SHADOW_OFFSET_Y = 5

  OFFSET_RATIO_AGAINST_PAPER_X = 0.03
  OFFSET_RATIO_AGAINST_PAPER_Y = 0.05

  TRANSPORT_DURATION = 0.5
  RESERVE_DURATION = 0.3
  REVERSE_DURATION = 0.4

  RELEASE_POSITION_ADJUST_RATIO = 0.7
  TRANSPORT_FIRST_VELOSITY = 0

  MAX_IMPACT_RADIUS_RATIO = 10

  # 単純移動平均の窓サイズ
  MAX_SPEED_WINDOW_SIZE = 30

  RECOVERY_TIME = 60
  DAMAGE_TIME = 10


  def initialize(x=0, y=0, width=100, height=100, pointer=nil, max_gaze_count=60, parent=nil, transport_target=nil,
                 option={})
    option = {:max_count_in_window=>60, :gaze_radius_ratio=>0.5, :max_count_in_gaze_area=>30,
              :is_view_impact_range=>false, :is_impact=>true, :impact_gain=>1.0, :name=>"poi", :id=>0, :target=>Window,
              :is_drag=>true}.merge(option)
    super()

    frame_image = Image.load(FRAME_IMAGE)
    shadow_image = frame_image.flush([64, 0, 0, 0])
    paper_normal_image = Image.load(PAPER_NORMAL_IMAGE)
    paper_break_image = Image.load(PAPER_BREAK_IMAGE)
    flash_image = Image.load(FLASH_IMAGE)
    break_flash_image = Image.load(BREAK_FLASH_IMAGE)

    images = [frame_image, shadow_image, paper_normal_image, paper_break_image, flash_image, break_flash_image]

    scale_x = width / frame_image.width.to_f if width
    scale_y = height / frame_image.height.to_f if height
    scale_x = scale_y unless width
    scale_y = scale_x unless height

    @images = []
    images.each do |image|
      @images.push(Images.scale_resize(image, scale_x, scale_y))
    end

    self.x = x
    self.y = y
    self.image = @images[2]
    @width = self.image.width
    @height = self.image.height
    self.collision = [@width * 0.5, @height * 0.5, @width * 0.5]
    self.target = option[:target]
    @gaze_range_image = Image.new(@width, @height * 1.05).circle_fill(@width * 0.5, @width * 0.5, @width * 0.5, C_RED)

    @id = option[:id]
    @name = option[:name]
    @is_drag = option[:is_drag]

    @pointer = pointer
    @max_count_in_window = option[:max_count_in_window]
    @gaze_radius = @width * option[:gaze_radius_ratio]
    @count_in_gaze_area = option[:max_count_in_gaze_area]
    @gaze_count = 0
    @max_gaze_count = max_gaze_count
    @gaze_range_scale = 0
    @parent = parent

    @windows = []
    @mode = :search

    @transport_target = transport_target
    @transport_count = 0

    @shadow_x = SHADOW_OFFSET_Y
    @shadow_y = SHADOW_OFFSET_Y

    @old_x = 0
    @old_y = 0

    @speed_windows = []
    @is_impact = option[:is_impact]
    @impact_gain = option[:impact_gain]
    @is_view_impact_range = option[:is_view_impact_range]

    @damage_sound = Sound.new(DAMAGE_SOUND)
    @flash_image = nil
    @final = false
  end

  def view_impact_range=(is_view_impact_range)
    @is_view_impact_range = is_view_impact_range
    @impact_range = Image.new(@width * MAX_IMPACT_RADIUS_RATIO, @height * MAX_IMPACT_RADIUS_RATIO)
  end

  def set_pos(x, y)
    self.x = x
    self.y = y
  end

  def update

    self.impact_range if @is_impact

    if @is_drag then
      self.x = @pointer.x - (@width * 0.5)
      self.y = @pointer.y - (@height * 0.5)
    end

    case @mode

    when :silent

    when :search
      self.search

    when :try_gaze
      self.try_gaze

    when :transport, :reserve, :reverse
      self.transport

    when :broke
      self.broke
    end

    if @is_damaged
      self.damage
    end
  end

  def impact_range

    delta_x, delta_y = self.x - @old_x, self.y - @old_y
    @old_x, @old_y = self.x, self.y

    if @speed_windows.size < MAX_SPEED_WINDOW_SIZE then
      @speed_windows.push(Math.sqrt(delta_x ** 2 + delta_y ** 2))
    else
      @speed_windows.shift(1)
    end

    # 単純移動平均
    if @speed_windows.size >= MAX_SPEED_WINDOW_SIZE then
      speed_average = @speed_windows.inject(:+) / @speed_windows.length
      @impact_radius = @impact_gain * speed_average ** 2
    end

    if @is_view_impact_range and @impact_radius then
      @impact_range.clear
      @impact_range.circle_fill(@impact_range.width * 0.5, @impact_range.height * 0.5, @impact_radius, [168, 0, 0, 255])
    end
  end

  def search

    if (@windows.size <= @max_count_in_window) then
      @windows.push([@pointer.x, @pointer.y])
    else
      @windows.shift(1)
    end

    if @windows.size >= @max_count_in_window then
      if self.gaze_point? then
        @windows.clear
        @mode = :try_gaze
        @is_drag = false
      end
    end
  end

  def gaze_point?

    inner_point_count = 0
    @windows.each do |window|
      inner_point_count += 1 if (window[0] - (self.x + (@width * 0.5))) ** 2 +
        ((window[1] - (self.y + (@height * 0.5))) ** 2) <= @gaze_radius ** 2
    end

    if inner_point_count >= @count_in_gaze_area then
      return true
    else
      return false
    end
  end

  def try_gaze

    if @pointer and (@pointer.x - (self.x + (@width * 0.5))) ** 2 +
      ((@pointer.y - (self.y + (@height * 0.5))) ** 2) <= (@width * 0.5) ** 2 then

      if @gaze_count < @max_gaze_count then
        @gaze_range_scale = 1 / @max_gaze_count.to_f * @gaze_count.to_f
        @gaze_count += 1
      else
        @gaze_range_scale = 0
        @gaze_count = 0
        @is_drag = true
        @parent.gazed(self.x, self.y, @width * 0.5, @height * 0.5) if @parent
      end
    else
      @gaze_range_scale = 0
      @gaze_count = 0
      @is_drag = true
      @mode = :search
    end
  end

  def transport

    @is_drag = false
    @is_impact = false

    if @transport_count <= TRANSPORT_DURATION then
      self.set_pos(@old_pos[0] + ease_in_out_quad(@transport_count, TRANSPORT_FIRST_VELOSITY,
                                                  @transport_target.x - @old_pos[0] + ((@width * 0.5) *
                                                    RELEASE_POSITION_ADJUST_RATIO), TRANSPORT_DURATION),
                   @old_pos[1] + ease_in_out_quad(@transport_count, TRANSPORT_FIRST_VELOSITY,
                                                  @transport_target.y - @old_pos[1] + ((@height * 0.5) *
                                                    RELEASE_POSITION_ADJUST_RATIO), TRANSPORT_DURATION))
      @transport_count += 0.01

    elsif @transport_count < TRANSPORT_DURATION + RESERVE_DURATION then
      @transport_count += 0.01

    elsif BigDecimal(@transport_count.to_s).round(2).to_f == TRANSPORT_DURATION + RESERVE_DURATION then
      @old_pos = [self.x, self.y]
      @transport_count += 0.01
      @mode = :reserve

    elsif @transport_count <= TRANSPORT_DURATION + RESERVE_DURATION + REVERSE_DURATION then
      self.set_pos(@old_pos[0] + ease_in_out_quad(@transport_count - (TRANSPORT_DURATION + RESERVE_DURATION),
                                                  TRANSPORT_FIRST_VELOSITY, @pointer.x - @old_pos[0] - (@width * 0.5),
                                                  REVERSE_DURATION),
                   @old_pos[1] + ease_in_out_quad(@transport_count - (TRANSPORT_DURATION + RESERVE_DURATION),
                                                  TRANSPORT_FIRST_VELOSITY, @pointer.y - @old_pos[1] - (@height * 0.5),
                                                  REVERSE_DURATION))
      @transport_count += 0.01
      @mode = :reverse
    else
      @transport_count = 0
      @is_drag = true
      @is_impact = true
      @mode = :search
    end
  end

  def set_break(final=false)
    @final = final
    @pre_mode = @mode
    @transport_count = 0
    @broke_count = 0
    @mode = :broke
    @damage_sound.play
  end

  def broke

    if @broke_count < RECOVERY_TIME / 3 then
      @flash_image = @images[5] unless self.image == @images[5]
      self.image = @images[3] unless self.image == @images[3]
      @broke_count += 1

    elsif @broke_count >= RECOVERY_TIME / 3 and @broke_count < RECOVERY_TIME then
      @flash_image = nil if @flash_image
      @broke_count += 1
    else
      self.image = @images[2] if not self.image == @images[2] and not @final
      if not @pre_mode == :transport and not  @pre_mode == :reserve then
        @broke_count = 0
        @is_drag = true
        @is_impact = true
        @mode = :search
      end
    end
    if @pre_mode == :transport or @pre_mode == :reserve then
      if @transport_count < RESERVE_DURATION then
        @transport_count += 0.01

      elsif BigDecimal(@transport_count.to_s).round(2).to_f == RESERVE_DURATION then
        @old_pos = [self.x, self.y]
        @transport_count += 0.01

      elsif @transport_count <= RESERVE_DURATION + REVERSE_DURATION then
        self.set_pos(@old_pos[0] + ease_in_out_quad(@transport_count - RESERVE_DURATION, TRANSPORT_FIRST_VELOSITY,
                                                    @pointer.x - @old_pos[0] - (@width * 0.5), REVERSE_DURATION),
                     @old_pos[1] + ease_in_out_quad(@transport_count - RESERVE_DURATION, TRANSPORT_FIRST_VELOSITY,
                                                    @pointer.y - @old_pos[1] - (@height * 0.5), REVERSE_DURATION))
        @transport_count += 0.01
      else
        @broke_count = 0
        @transport_count = 0
        @is_drag = true
        @is_impact = true
        @mode = :search
      end
    end
  end

  def set_damage
    @damage_count = 0
    @is_damaged = true
    @damage_sound.play
  end

  def damage
    if @damage_count < DAMAGE_TIME then
      @flash_image = @images[4] if self.image == @images[2] and not @flash_image == @images[4]
      @flash_image = @images[5] if self.image == @images[3] and not @flash_image == @images[5]
      @damage_count += 1
    else
      @is_damaged = false
      @flash_image = nil
      @damage_count = 0
    end
  end

  def hit(obj)

  end

  def draw

    self.target.draw(self.x - (@width * OFFSET_RATIO_AGAINST_PAPER_X) + @shadow_x,
                     self.y - (@height * OFFSET_RATIO_AGAINST_PAPER_Y) + @shadow_y, @images[1], self.z)

    self.target.draw_ex(self.x, self.y, self.image, {:z=>self.z, :alpha=>128})

    self.target.draw_ex(self.x, self.y,
                        @gaze_range_image, {:z=>self.z, :scale_x=>@gaze_range_scale,
                                            :scale_y=>@gaze_range_scale, :alpha=>128}) if @mode == :try_gaze

    self.target.draw(self.x - (@width * OFFSET_RATIO_AGAINST_PAPER_X),
                     self.y - (@height * OFFSET_RATIO_AGAINST_PAPER_Y), @images[0], self.z)

    self.target.draw(self.x - (@width * OFFSET_RATIO_AGAINST_PAPER_X),
                     self.y - (@height * OFFSET_RATIO_AGAINST_PAPER_Y), @flash_image, self.z) if @flash_image

    self.target.draw(self.x - (@impact_range.width - @width) * 0.5, self.y - (@impact_range.height - @height) * 0.5,
                     @impact_range, self.z) if @is_view_impact_range
  end
end


if __FILE__ == $0 then

  Window.width = 1980
  Window.height = 1080

  MAX_COUNT_IN_WINDOW = 60
  MAX_COUNT_IN_GAZE_AREA = 30
  MAX_GAZE_COUNT = 60

  POI_HEIGHT_SIZE = Window.height * 0.35
  POI_GAZE_RADIUS_RATIO = 0.5

  @mouse = Sprite.new(0, 0)
  @poi = Poi.new(0, 0, nil, POI_HEIGHT_SIZE, @mouse,
                 MAX_GAZE_COUNT, nil, {:max_count_in_window=>MAX_COUNT_IN_WINDOW,
                                  :gaze_radius_ratio=>POI_GAZE_RADIUS_RATIO, :max_count_in_gaze_area=>MAX_COUNT_IN_GAZE_AREA})
  @poi.view_impact_range = true

  Window.bgcolor = C_GREEN
  Window.loop do
    @mouse.x, @mouse.y = Input.mouse_pos_x, Input.mouse_pos_y
    @poi.update
    @poi.draw
  end
end
