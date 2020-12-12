#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

require "dxruby"
require "bigdecimal"

if __FILE__ == $0 then
  require "../lib/dxruby/easing"
  POI_FRAME_IMAGE = "../images/poi_frame.png"
  POI_SHADOW_IMAGE = "../images/poi_frame_shadow.png"
  POI_PAPER_NORMAL_IMAGE = "../images/poi_paper_0.png"
  POI_PAPER_BREAK_IMAGE = "../images/poi_paper_1.png"
else
  require "./lib/dxruby/easing"
  POI_FRAME_IMAGE = "./images/poi_frame.png"
  POI_SHADOW_IMAGE = "./images/poi_frame_shadow.png"
  POI_PAPER_NORMAL_IMAGE = "./images/poi_paper_0.png"
  POI_PAPER_BREAK_IMAGE = "./images/poi_paper_1.png"
end

POI_SHADOW_OFFSET_X = 5
POI_SHADOW_OFFSET_Y = 5

POI_PAPER_OFFSET_RATIO_AGAINST_FRAME_X = 0.03
POI_PAPER_OFFSET_RATIO_AGAINST_FRAME_Y = 0.03

POI_GAZE_AREA_RADIUS_AGAINST_POI_PAPER_RATIO = 0.5
POI_POINT_COUNT_IN_GAZE_AREA = 30

POI_CATCH_COUNT = 60
POI_TRANSPORT_DURATION = 0.5
POI_RESERVE_DURATION = 0.3
POI_REVERSE_DURATION = 0.4

POI_RESERVED_OBJECT_Z_POSITION = 200
POI_DEEP_DIVE_OBJECT_Z_POSITION = 0

POI_RESERVE_ADJUST_TARGET_RANGE_RATIO = 0.55
POI_RELEASE_POSITION_ADJUST_RATIO = 0.7
POI_TRANSPORT_FIRST_VELOSITY = 0

class Poi <Sprite

  include Easing

  attr_accessor :id, :name, :is_drag, :mode
  attr_reader :width, :height

  def initialize(x, y, scale=1, follow_target=nil, transport_target=nil, parent=nil, id=0, target=Window, is_drag=true)
    super()

    poi_frame_image = Image.load(POI_FRAME_IMAGE)
    poi_shadow_image0 = Image.load(POI_SHADOW_IMAGE)
    poi_shadow_image = poi_shadow_image0.flush([64, 0, 0, 0])
    poi_paper_normal_image = Image.load(POI_PAPER_NORMAL_IMAGE)
    poi_paper_break_image = Image.load(POI_PAPER_BREAK_IMAGE)

    poi_images = [poi_frame_image, poi_shadow_image, poi_paper_normal_image, poi_paper_break_image]

    @poi_images = []
    poi_images.each do |poi_image|
      render_target = RenderTarget.new(poi_image.width * scale, poi_image.height * scale)
      render_target.draw_scale(poi_image.width * (scale - 1.0) * 0.5, poi_image.height * (scale - 1.0) * 0.5, poi_image, scale, scale)
      @poi_images.push(render_target.to_image)
      poi_image.dispose
      render_target.dispose
    end

    self.x = x
    self.y = y
    self.image = @poi_images[2]
    @width = self.image.width
    @height = self.image.height
    self.collision = [@width * 0.5, @height * 0.5, @width * 0.5]
    self.target = target
    @catch_range_image = Image.new(@width, @height + 10).circle_fill(@width * 0.5, @width * 0.5, @width * 0.5, C_RED)
    @id = id
    @name = "poi"
    @is_drag = is_drag
    @gaze_area_radius = @width * POI_GAZE_AREA_RADIUS_AGAINST_POI_PAPER_RATIO
    @gaze_count = 0
    @div_catch_count = 1 / POI_CATCH_COUNT.to_f
    @catch_range_scale = 0
    @transport_count = 0
    @follow_target = follow_target
    @transport_target = transport_target
    @parent = parent
    @mode = :normal
  end

  def update

    case @mode
    when :normal

    when :try_gaze
      self.try_gaze

    when :transport
      self.transport
    end
  end

  def search_gaze_point(windows)

    inner_point_count = 0
    windows.each do |window|
      inner_point_count += 1 if (window[0] - (self.x + (@width * 0.5))) ** 2 + ((window[1] - (self.y + (@height * 0.5))) ** 2) <= @gaze_area_radius ** 2
    end

    if inner_point_count >= POI_POINT_COUNT_IN_GAZE_AREA then
      return true
    else
      return false
    end
  end

  def try_gaze

    if @follow_target and (@follow_target.x - (self.x + (@width * 0.5))) ** 2 + ((@follow_target.y - (self.y + (@height * 0.5))) ** 2) <= (@width * 0.5) ** 2 then
      if @gaze_count < POI_CATCH_COUNT then
        @catch_range_scale = @div_catch_count * @gaze_count.to_f
        @gaze_count += 1
      else
        @catch_range_scale = 0
        @gaze_count = 0
        @is_drag = true
        @mode = :try_catch
      end
    else
      @catch_range_scale = 0
      @gaze_count = 0
      @is_drag = true
      @mode = :normal
    end
  end

  def try_catch(catch_objects)

    @catch_objects = catch_objects
    unless @catch_objects.empty? then
      @old_pos = [self.x, self.y]
      @mode = :transport
    else
      @mode = :normal
    end
  end

  def transport

    @is_drag = false
    if @transport_count <= POI_TRANSPORT_DURATION then
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
    self.target.draw(self.x + POI_SHADOW_OFFSET_X, self.y + POI_SHADOW_OFFSET_Y, @poi_images[1], self.z)
    self.target.draw_ex(self.x + (@poi_images[0].width * POI_PAPER_OFFSET_RATIO_AGAINST_FRAME_X), self.y + (@poi_images[0].height * POI_PAPER_OFFSET_RATIO_AGAINST_FRAME_Y), self.image, {:z=>self.z, :alpha=>128})
    self.target.draw_ex(self.x + (@catch_range_image.width * POI_PAPER_OFFSET_RATIO_AGAINST_FRAME_X), self.y + (@catch_range_image.height * POI_PAPER_OFFSET_RATIO_AGAINST_FRAME_Y), @catch_range_image, {:z=>self.z, :scale_x=>@catch_range_scale, :scale_y=>@catch_range_scale, :alpha=>128}) if @mode == :try_gaze
    self.target.draw(self.x, self.y, @poi_images[0], self.z)
  end
end


if __FILE__ == $0 then

  class Mouse < Sprite
    attr_reader :name

    def initialize
      super()
      self.collision = [0, 0]
    end
  end
  @mouse = Mouse.new

  @poi = Poi.new(0, 0, 0.8, @mouse)

  def mouseProcess

    @mouse.x, @mouse.y = Input.mouse_pos_x, Input.mouse_pos_y

    if @poi.is_drag then
      @poi.x = @mouse.x - (@poi.width * 0.5)
      @poi.y = @mouse.y - (@poi.height * 0.5)
    end
  end

  Window.width = 1920
  Window.height = 1080

  windows = []

  POINT_COUNT_IN_WINDOW = 60

  Window.bgcolor = C_GREEN
  Window.loop do

    mouseProcess

    unless @poi.mode == :try_gaze then
      if (windows.size <= POI_POINT_COUNT_IN_WINDOW) then
        windows.push([@mouse.x, @mouse.y])
      else
        windows.shift(1)
      end

      if windows.size >= POI_POINT_COUNT_IN_WINDOW then
        if @poi.search_gaze_point(windows) then
          windows.clear
          @poi.mode = :try_gaze
          @poi.is_drag = false
        end
      end
    end
    @poi.update
    @poi.draw
  end
end
