#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

require "dxruby"




RESERVED_OBJECT_Z_POSITION = 200
DEEP_DIVE_OBJECT_Z_POSITION = 0
RESERVE_ADJUST_TARGET_RANGE_RATIO = 0.55



class Poi <Sprite

  attr_accessor :name, :id, :is_drag, :mode, :old_pos
  attr_reader :width, :height

  require "bigdecimal"

  if __FILE__ == $0 then
    require "../lib/dxruby/images"
    require "../lib/dxruby/easing"
    FRAME_IMAGE = "../images/poi_frame.png"
    SHADOW_IMAGE = "../images/poi_frame_shadow.png"
    PAPER_NORMAL_IMAGE = "../images/poi_paper_0.png"
    PAPER_BREAK_IMAGE = "../images/poi_paper_1.png"
  else
    require "./lib/dxruby/images"
    require "./lib/dxruby/easing"
    FRAME_IMAGE = "./images/poi_frame.png"
    SHADOW_IMAGE = "./images/poi_frame_shadow.png"
    PAPER_NORMAL_IMAGE = "./images/poi_paper_0.png"
    PAPER_BREAK_IMAGE = "./images/poi_paper_1.png"
  end

  include Easing

  SHADOW_OFFSET_X = 5
  SHADOW_OFFSET_Y = 5

  PAPER_OFFSET_RATIO_AGAINST_FRAME_X = 0.03
  PAPER_OFFSET_RATIO_AGAINST_FRAME_Y = 0.03

  TRANSPORT_DURATION = 0.5
  RESERVE_DURATION = 0.3
  REVERSE_DURATION = 0.4

  RELEASE_POSITION_ADJUST_RATIO = 0.7
  TRANSPORT_FIRST_VELOSITY = 0


  def initialize(x=0, y=0, width=100, height=100, pointer=nil, max_gaze_count=60, parent=nil, transport_target=nil, option={})
    option = {:max_count_in_window=>60, :gaze_radius_ratio=>0.5, :max_count_in_gaze_area=>30,
              :name=>"poi", :id=>0, :target=>Window, :is_drag=>true}.merge(option)
    super()

    frame_image = Image.load(FRAME_IMAGE)
    shadow_image0 = Image.load(SHADOW_IMAGE)
    shadow_image = shadow_image0.flush([64, 0, 0, 0])
    paper_normal_image = Image.load(PAPER_NORMAL_IMAGE)
    paper_break_image = Image.load(PAPER_BREAK_IMAGE)
    shadow_image0.dispose

    images = [frame_image, shadow_image, paper_normal_image, paper_break_image]

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
  end

  def set_pos(x, y)
    self.x = x
    self.y = y
  end

  def update

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

    when :transport, :reserve
      self.transport
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
      inner_point_count += 1 if
        (window[0] - (self.x + (@width * 0.5))) ** 2 + ((window[1] - (self.y + (@height * 0.5))) ** 2) <= @gaze_radius ** 2
    end

    if inner_point_count >= @count_in_gaze_area then
      return true
    else
      return false
    end
  end

  def try_gaze

    if @pointer and (@pointer.x - (self.x + (@width * 0.5))) ** 2 + ((@pointer.y - (self.y + (@height * 0.5))) ** 2) <= (@width * 0.5) ** 2 then
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
    if @transport_count <= TRANSPORT_DURATION then
      self.set_pos(@old_pos[0] + ease_in_out_quad(@transport_count, TRANSPORT_FIRST_VELOSITY,
                                                  @transport_target.x - @old_pos[0] + ((@width * 0.5) * RELEASE_POSITION_ADJUST_RATIO),
                                                  TRANSPORT_DURATION),
                   @old_pos[1] + ease_in_out_quad(@transport_count, TRANSPORT_FIRST_VELOSITY,
                                                  @transport_target.y - @old_pos[1] + ((@height * 0.5) * RELEASE_POSITION_ADJUST_RATIO),
                                                  TRANSPORT_DURATION))
      @transport_count += 0.01

    elsif @transport_count < TRANSPORT_DURATION + RESERVE_DURATION then
      @transport_count += 0.01

    elsif BigDecimal(@transport_count.to_s).floor(2).to_f == TRANSPORT_DURATION + RESERVE_DURATION then
      @old_pos = [self.x, self.y]
      @transport_count += 0.01
      @mode = :reserve

    elsif @transport_count <= TRANSPORT_DURATION + RESERVE_DURATION + REVERSE_DURATION then
      self.set_pos(@old_pos[0] + ease_in_out_quad(@transport_count - (TRANSPORT_DURATION + RESERVE_DURATION), TRANSPORT_FIRST_VELOSITY,
                                                  @pointer.x - @old_pos[0] - (@width * 0.5), REVERSE_DURATION),
                   @old_pos[1] + ease_in_out_quad(@transport_count - (TRANSPORT_DURATION + RESERVE_DURATION), TRANSPORT_FIRST_VELOSITY,
                                                  @pointer.y - @old_pos[1] - (@height * 0.5), REVERSE_DURATION))
      @transport_count += 0.01

    else
      @transport_count = 0
      @is_drag = true
      @mode = :search
    end
  end

  def transport2

    @is_drag = false
    if @transport_count <= TRANSPORT_DURATION then
      self.x = @old_pos[0] + ease_in_out_quad(@transport_count, POI_TRANSPORT_FIRST_VELOSITY, @transport_target.x - @old_pos[0] + ((@width * 0.5) * POI_RELEASE_POSITION_ADJUST_RATIO), POI_TRANSPORT_DURATION)
      self.y = @old_pos[1] + ease_in_out_quad(@transport_count, POI_TRANSPORT_FIRST_VELOSITY, @transport_target.y - @old_pos[1] + ((@height * 0.5) * POI_RELEASE_POSITION_ADJUST_RATIO), POI_TRANSPORT_DURATION)

      @catch_objects.each do |catch_object|
        catch_object[0].x = self.x + catch_object[1][0]
        catch_object[0].y = self.y + catch_object[1][1]
      end
      @transport_count += 0.01

    elsif @transport_count < POI_TRANSPORT_DURATION + POI_RESERVE_DURATION then
      @transport_count += 0.01

    elsif BigDecimal(@transport_count.to_s).floor(2).to_f == POI_TRANSPORT_DURATION + POI_RESERVE_DURATION then
      scoring_targets = []
      @catch_objects.each do |catch_object|
        if (catch_object[0].x + catch_object[0].center_x - (@transport_target.x + (@transport_target.width * 0.5))) ** 2 + ((catch_object[0].y + catch_object[0].center_y - (@transport_target.y + (@transport_target.height * 0.5))) ** 2) <= (@transport_target.width * 0.5 * POI_RESERVE_ADJUST_TARGET_RANGE_RATIO) ** 2 then
          catch_object[0].z = POI_RESERVED_OBJECT_Z_POSITION
          catch_object[0].is_reserved = true
          catch_object[0].mode = :reserved
          scoring_targets.push(catch_object[0])
          @parent.scoring(scoring_targets)
        end
      end
      @old_pos = [self.x, self.y]
      @catch_objects.clear
      @transport_count += 0.01

    elsif @transport_count <= POI_TRANSPORT_DURATION + POI_RESERVE_DURATION + POI_REVERSE_DURATION then
      self.x = @old_pos[0] + ease_in_out_quad(@transport_count - (POI_TRANSPORT_DURATION + POI_RESERVE_DURATION), POI_TRANSPORT_FIRST_VELOSITY, @follow_target.x - @old_pos[0] - (@width * 0.5), POI_REVERSE_DURATION)
      self.y = @old_pos[1] + ease_in_out_quad(@transport_count - (POI_TRANSPORT_DURATION + POI_RESERVE_DURATION), POI_TRANSPORT_FIRST_VELOSITY, @follow_target.y - @old_pos[1] - (@height * 0.5), POI_REVERSE_DURATION)
      @transport_count += 0.01

    else
      @transport_count = 0
      @is_drag = true
      @mode = :normal
    end
  end

  def hit(obj)

  end

  def draw
    self.target.draw(self.x + SHADOW_OFFSET_X, self.y + SHADOW_OFFSET_Y, @images[1], self.z)
    self.target.draw_ex(self.x + (@images[0].width * PAPER_OFFSET_RATIO_AGAINST_FRAME_X),
                        self.y + (@images[0].height * PAPER_OFFSET_RATIO_AGAINST_FRAME_Y), self.image, {:z=>self.z, :alpha=>128})
    self.target.draw_ex(self.x + (@gaze_range_image.width * PAPER_OFFSET_RATIO_AGAINST_FRAME_X),
                        self.y + (@gaze_range_image.height * PAPER_OFFSET_RATIO_AGAINST_FRAME_Y),
                        @gaze_range_image, {:z=>self.z, :scale_x=>@gaze_range_scale, :scale_y=>@gaze_range_scale, :alpha=>128}) if @mode == :try_gaze
    self.target.draw(self.x, self.y, @images[0], self.z)
  end
end


if __FILE__ == $0 then

  Window.width = 1980
  Window.height = 1080

  MAX_COUNT_IN_WINDOW = 60
  MAX_COUNT_IN_GAZE_AREA = 30
  MAX_GAZE_COUNT = 60

  POI_HEIGHT_SIZE = Window.height * 0.4
  POI_GAZE_RADIUS_RATIO = 0.5

  @mouse = Sprite.new(0, 0)
  @poi = Poi.new(0, 0, nil, POI_HEIGHT_SIZE, @mouse,
                 MAX_GAZE_COUNT, nil, {:max_count_in_window=>MAX_COUNT_IN_WINDOW,
                                  :gaze_radius_ratio=>POI_GAZE_RADIUS_RATIO, :max_count_in_gaze_area=>MAX_COUNT_IN_GAZE_AREA})

  Window.bgcolor = C_GREEN
  Window.loop do
    @mouse.x, @mouse.y = Input.mouse_pos_x, Input.mouse_pos_y
    @poi.update
    @poi.draw
  end
end
