#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

require "dxruby"

if __FILE__ == $0 then
  POI_FRAME_IMAGE = "../images/poi_frame.png"
  POI_SHADOW_IMAGE = "../images/poi_frame_shadow.png"
  POI_PAPER_NORMAL_IMAGE = "../images/poi_paper_0.png"
  POI_PAPER_BREAK_IMAGE = "../images/poi_paper_1.png"
else
  POI_FRAME_IMAGE = "./images/poi_frame.png"
  POI_SHADOW_IMAGE = "./images/poi_frame_shadow.png"
  POI_PAPER_NORMAL_IMAGE = "./images/poi_paper_0.png"
  POI_PAPER_BREAK_IMAGE = "./images/poi_paper_1.png"
end

POI_SHADOW_OFFSET_X = 5
POI_SHADOW_OFFSET_Y = 5

POI_PAPER_OFFSET_RATIO_AGAINST_FRAME_X = 0.03
POI_PAPER_OFFSET_RATIO_AGAINST_FRAME_Y = 0.03

GAZE_AREA_RADIUS_AGAINST_POI_PAPER_RATIO = 0.5
POINT_COUNT_IN_GAZE_AREA = 30

CATCH_COUNT = 60


class Poi <Sprite

  attr_accessor :id, :name, :is_drag, :mode
  attr_reader :width, :height

  def initialize(x, y, scale=1, id=0, target=Window, is_drag=true)
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
    @gaze_area_radius = @width * GAZE_AREA_RADIUS_AGAINST_POI_PAPER_RATIO
    @is_try_gaze = false
    @gaze_count = 0
    @div_catch_count = 1 / CATCH_COUNT.to_f
    @catch_range_scale = 0
    @catch_objects = []
    @inner_diffs = []
    @transport_count = 0
    @mode = "normal"
  end

  def update
    case @mode

    when "normal"

    when "try_gaze"
      self.try_gaze

    when "transport"
      self.transport
    end
  end

  def search_gaze_point(windows)

    inner_point_count = 0
    windows.each do |window|
      inner_point_count += 1 if (window[0] - (self.x + (@width * 0.5))) ** 2 + ((window[1] - (self.y + (@height * 0.5))) ** 2) <= @gaze_area_radius ** 2
    end

    if inner_point_count >= POINT_COUNT_IN_GAZE_AREA then
      return true
    else
      return false
    end
  end

  def try_gaze

    if @mouse and (@mouse.x - (self.x + (@width * 0.5))) ** 2 + ((@mouse.y - (self.y + (@height * 0.5))) ** 2) <= (@width * 0.5) ** 2 then
      if @gaze_count < CATCH_COUNT then
        @catch_range_scale = @div_catch_count * @gaze_count.to_f
        @gaze_count += 1
      else
        @catch_range_scale = 0
        @gaze_count = 0
        @is_drag = true
        self.try_catch
      end
    else
      @catch_range_scale = 0
      @gaze_count = 0
      @is_drag = true
      @mode = "normal"
    end
  end

  def try_catch

    unless @catch_objects.empty? then
      @catch_objects.each do |catch_object|
        if (catch_object.x + catch_object.center_x - (self.x + (@width * 0.5))) ** 2 + (catch_object.y + catch_object.center_y - (@mouse.y - (self.y + (@height * 0.5))) ** 2) <= (@width * 0.5) ** 2 - 30 then
          @inner_diffs.push([catch_object, [catch_object.x - self.x, catch_object.y - self.y]])
          catch_object.mode = "catched"
        else
          @catch_objects.delete(catch_object)
        end
      end
      @mode = "transport"
    else
      @mode = "normal"
    end
  end

  def transport
    if @transport_count <= 600 then
      @catch_objects.each do |catch_object|
        @inner_diffs.each do |inner_diff|
          if inner_diff[0] == catch_object then
            catch_object.x = self.x + inner_diff[1][0]
            catch_object.y = self.y + inner_diff[1][1]
          end
        end
      end
      @transport_count += 1
    else
      @transport_count = 0
      @catch_objects.clear
      @inner_diffs.clear
      @mode = "normal"
    end

  end

  def hit(obj)

    case obj.name

    when "mouse"
      @mouse = obj if @mode == "try_gaze"

    when "red_kingyo", "black_kingyo"
      if @mode == "try_gaze" then
        @catch_objects.push(obj) unless @catch_objects.include?(obj)
      end
    end
  end

  def draw
    self.target.draw(self.x + POI_SHADOW_OFFSET_X, self.y + POI_SHADOW_OFFSET_Y, @poi_images[1])
    self.target.draw_ex(self.x + (@poi_images[0].width * POI_PAPER_OFFSET_RATIO_AGAINST_FRAME_X), self.y + (@poi_images[0].height * POI_PAPER_OFFSET_RATIO_AGAINST_FRAME_Y), self.image, :alpha=>128)
    self.target.draw_ex(self.x + (@catch_range_image.width * POI_PAPER_OFFSET_RATIO_AGAINST_FRAME_X), self.y + (@catch_range_image.height * POI_PAPER_OFFSET_RATIO_AGAINST_FRAME_Y), @catch_range_image, :scale_x=>@catch_range_scale, :scale_y=>@catch_range_scale, :alpha=>128) if @mode == "try_gaze"
    self.target.draw(self.x, self.y, @poi_images[0])
  end
end


if __FILE__ == $0 then

  class Mouse < Sprite
    attr_reader :name

    def initialize
      super()
      self.collision = [0, 0]
      @name = "mouse"
    end
  end
  @mouse = Mouse.new

  @poi = Poi.new(0, 0, 0.8)

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

  Window.bgcolor = C_GREEN
  Window.loop do

    mouseProcess

    unless @poi.mode == "try_gaze" then
      if (windows.size <= POINT_COUNT_IN_GAZE_AREA) then
        windows.push([@mouse.x, @mouse.y])
      else
        windows.shift(1)
      end

      if windows.size >= POINT_COUNT_IN_GAZE_AREA then
        if @poi.search_gaze_point(windows) then
          windows.clear
          @poi.mode = "try_gaze"
          @poi.is_drag = false
        end
      end
    end

    Sprite.check(@mouse, @poi) if @poi.mode == "try_gaze" or @poi.mode == "try_catch"

    @poi.update
    @poi.draw
  end
end
