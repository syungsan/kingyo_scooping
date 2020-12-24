#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

# images.rb Ver 1.1
# 汎用描画ライブラリ

require "dxruby"


class Images

  attr_accessor :x, :y, :id, :name, :is_pen_active, :pen_size, :pen_color, :is_innovative_line, 
                :is_legacy_line, :target, :scale_x, :scale_y, :angle, :alpha
  attr_reader :width, :height, :string, :font_size

  def initialize(x=0, y=0, width=50, height=40, string= "", font_size=28, color=C_WHITE, st_color=C_BLACK,
                 id=0, name="images", option={})
    option = {:font_name=>"ＭＳ Ｐゴシック", :is_pen_active=>false, :pen_size=>5, :pen_color=>C_BLACK, 
              :is_innovative_line=>true, :is_legacy_line=>false, :target=>Window}.merge(option)

    self.target = option[:target]
    self.x = x
    self.y = y
    @filename = nil
    @copy_name = nil
    @stretch_filename = nil
    @width = width
    @height = height
    @color = color
    @font_size = font_size
    @st_color = st_color
    @font_name = option[:font_name]
    @string = string
    @string_pos = []
    self.construct
    self.name = name
    self.id = id
    self.is_pen_active = option[:is_pen_active]
    self.pen_size = option[:pen_size]
    self.pen_color = option[:pen_color]
    self.is_innovative_line = option[:is_innovative_line]
    self.is_legacy_line = option[:is_legacy_line]

    @cur_x, @cur_y = nil,
    @is_paint = false
    @is_grid = false
    @is_frame = false
  end

  def set_pos(x, y)
    self.x = x
    self.y = y
  end

  def construct

    @image.dispose if @image and not @image.disposed?
    @image = Image.new(@width, @height, @color)
    
    self.set_image if @filename or @copy_name
    self.set_stretch_image if @stretch_filename

    self.grid(@division_numbers, @grid_line_width, @grid_line_color) if @is_grid
    self.frame(@frame_color, @frame_size) if @is_frame
    self.draw_string if @string != ""
  end

  def string(string, font_size=28, st_color=C_BLACK)
    @string = string
    @font_size = font_size
    @st_color = st_color
    self.construct
  end

  def string=(string)
    @string = string
    self.construct
  end

  def string_pos(string, font_size, x, y, color)
    @string = string
    @font_size = font_size
    @st_color = color
    @string_pos = [x, y]
    self.construct
  end

  def font_size=(font_size)
    @font_size = font_size
    self.construct
  end

  def font_color=(font_color)
    @st_color = font_color
    self.construct
  end

  def font_name=(font_name)
    @font_name = font_name
    self.construct
  end

  def draw_string

    @font = Font.new(@font_size, @font_name)

    if @string.include?("\n") then
      strings = @string.split("\n")

      for loop_id in 0...strings.size do

        unless @string_pos.empty? then
          @image.draw_font(@string_pos[0], @string_pos[1] + @font.size * loop_id, strings[loop_id], @font, @st_color)
        else
          string_width = @font.get_width(strings[loop_id])
          @image.draw_font((@width - string_width) * 0.5, (@height - (@font.size * strings.size)) * 0.5 + 
            @font.size * loop_id, strings[loop_id], @font, @st_color)
        end
      end
    else
      unless @string_pos.empty? then
        @image.draw_font(@string_pos[0], @string_pos[1], @string, @font, @st_color)
      else
        string_width = @font.get_width(@string)
        @image.draw_font((@width - string_width) * 0.5, (@height - @font.size) * 0.5, @string, @font, @st_color)
      end
    end
    @font.dispose
  end

  def image(filename)
    @filename = filename
    self.construct
  end

  def set_image
    @image.dispose if @image and not @image.disposed?
    image = Image.load(@filename) if @filename
    image = @copy_name if @copy_name
    @width = image.width
    @height = image.height
    @image = image
  end

  def stretch_image(width, height, stretch_filename)
    @stretch_filename = stretch_filename
    @width = width
    @height = height
    self.construct
  end

  def set_stretch_image
    @image.dispose if @image and not @image.disposed?
    image = Image.load(@stretch_filename)
    @image = RenderTarget.new(@width, @height).draw_scale(0, 0, image, @width / image.width.to_f,
                                                          @height / image.height.to_f, 0, 0).update.to_image
  end

  def get_image
    return @image
  end

  def copy_image(copy_name)
    @copy_name = copy_name
    self.construct
  end

  def frame(frame_color=C_BLACK, frame_size=2)

    @frame_color = frame_color
    @frame_size = frame_size
    @is_frame = true

    @image.box_fill(0, 0, @width,  @frame_size - 1, @frame_color) # 上辺
    @image.box_fill(0, 0, @frame_size - 1 , @height, @frame_color) # 左辺
    @image.box_fill(@width - @frame_size, 0, @width , @height, @frame_color) # 右辺
    @image.box_fill(0, @height - @frame_size, @width , @height, @frame_color) # 左辺
  end

  def update
    self.pen if self.is_pen_active
  end

  def pen

    old_x, old_y = @cur_x, @cur_y
    @cur_x, @cur_y = Input.mouse_pos_x - self.x, Input.mouse_pos_y - self.y

    # ボタンを押している間の処理
    if Input.mouse_down?(M_LBUTTON) then

      # エッジに円を描画
      @image.circle_fill(@cur_x, @cur_y, self.pen_size, self.pen_color) unless @is_paint
      @is_paint = true
      @image.circle_fill(@cur_x, @cur_y, self.pen_size, self.pen_color) if self.is_legacy_line

      if self.is_innovative_line then

        # 円形ペン描画（勝又スペシャル）###################################################
        # line数が多いので割とカクつく
        for i in 0...360 do # 回転角度θをi
          for j in self.pen_size-1..self.pen_size do # 円の厚み0からに指定で中実円 かすれない程度に厚く
            @image.line(@cur_x+j*Math.cos(i*Math::PI/180), @cur_y+j*Math.sin(i*Math::PI/180),
                       old_x+j*Math.cos(i*Math::PI/180),old_y+j*Math.sin(i*Math::PI/180),self.pen_color)  # i*j本の線を描画
          end
        end
        # image.circle_fill(@cur_x, @cur_y, 10, self.pen_color) # jが0からなら要らない書き出しの塗りつぶし用（line数削減で負荷軽減用）
      end

      if self.is_legacy_line then

        for loop_id in 0...self.pen_size do

          # エッジの回転アリ（多々納スペシャル）##########################
          theta = Math.atan2(@cur_y - old_y, @cur_x - old_x)

          cur_rx = loop_id * Math.cos((Math::PI * 0.5) + theta) + @cur_x
          cur_ry = loop_id * Math.sin((Math::PI * 0.5) + theta) + @cur_y

          old_rx = loop_id * Math.cos((Math::PI * 0.5) + theta) + old_x
          old_ry = loop_id * Math.sin((Math::PI * 0.5) + theta) + old_y

          # 反対側も
          cur_lx = loop_id * Math.cos(-1 * (Math::PI * 0.5) + theta) + @cur_x
          cur_ly = loop_id * Math.sin(-1 * (Math::PI * 0.5) + theta) + @cur_y

          old_lx = loop_id * Math.cos(-1 * (Math::PI * 0.5) + theta) + old_x
          old_ly = loop_id * Math.sin(-1 * (Math::PI * 0.5) + theta) + old_y

          @image.line(cur_lx, cur_ly, old_lx, old_ly, self.pen_color)
          @image.line(cur_rx, cur_ry, old_rx, old_ry, self.pen_color)

          # エッジの回転ナシ（荒木スペシャル）############################
          new_right_x = @cur_x + loop_id
          new_left_x = @cur_x - loop_id
          new_zero_y = @cur_y

          old_right_x = old_x + loop_id
          old_left_x = old_x - loop_id
          old_zero_y = old_y

          new_up_y = @cur_y - loop_id
          new_down_y = @cur_y + loop_id
          new_zero_x = @cur_x

          old_up_y = old_y - loop_id
          old_down_y = old_y + loop_id
          old_zero_x = old_x

          @image.line(new_right_x, new_zero_y, old_right_x, old_zero_y, self.pen_color)
          @image.line(new_left_x, new_zero_y, old_left_x, old_zero_y, self.pen_color)
          @image.line(new_zero_x, new_up_y, old_zero_x, old_up_y, self.pen_color)
          @image.line(new_zero_x, new_down_y, old_zero_x, old_down_y, self.pen_color)
        end
      end
    else
      @is_paint = false
    end
  end

  def get_paint_chart
    if self.is_pen_active then
      if @is_paint then
        if @cur_x >= 0 and @cur_x <= @width and @cur_y >= 0 and @cur_y <= @height then
          chart = [@cur_x, @cur_y]
        else
          chart = [nil, nil]
        end
        return chart
      else
        chart = [nil, nil]
      end
      return chart
    else
      puts "not set pen active..."
    end
  end

  def grid(division_numbers, grid_line_width, grid_line_color)

    @is_grid = true

    @division_numbers = division_numbers
    @grid_line_width = grid_line_width
    @grid_line_color = grid_line_color

    (@division_numbers[0] + 1).times do |loop_id|
      @image.box_fill(0, (@height - @grid_line_width) / @division_numbers[0] * loop_id, 
                      @width, ((@height - @grid_line_width) / @division_numbers[0] * loop_id) + @grid_line_width, @grid_line_color)
    end
    (@division_numbers[1] + 1).times do |loop_id|
      @image.box_fill((@width - @grid_line_width) / @division_numbers[1] * loop_id, 
                      0, ((@width - @grid_line_width) / @division_numbers[1] * loop_id) + @grid_line_width, @height, @grid_line_color)
    end
  end

  def clear
    @image.dispose if @image
    @filename = nil unless@filename.nil?
    @string = "" unless @string == ""
    @is_paint = false
    @is_grid = false
    @is_frame = false
    self.construct
  end

  def width=(width)
    @width = width
    self.construct
  end

  def height=(height)
    @height = height
    self.construct
  end

  def color=(color)
    @color = color
    self.construct
  end

  def save(file_path)
    @image.save(file_path)
  end

  def render
    self.target.draw_ex(self.x, self.y, @image, {:scale_x=>self.scale_x, :scale_y=>self.scale_y, :angle=>self.angle, :alpha=>self.alpha})
  end

  def scale_render(sx, sy)
    self.target.draw_scale(self.x, self.y, @image, sx, sy, 0, 0)
  end

  def alpha_render(alpha)
    self.target.draw_alpha(self.x, self.y, @image, alpha)
  end

  def rot_render(angle)
    self.target.draw_rot(self.x, self.y, @image, angle)
  end


  class << self

    def fit_resize(image, width, height)
      render_target = RenderTarget.new(width, height)
      dist_image = render_target.draw_scale(0, 0, image, width / image.width.to_f, height / image.height.to_f, 0, 0).to_image
      image.dispose
      render_target.dispose
      return dist_image
    end

    def scale_resize(image, scale_x, scale_y)
      render_target = RenderTarget.new(image.width * scale_x, image.height * scale_y)
      dist_image = render_target.draw_scale(0, 0, image, scale_x, scale_y, 0, 0).to_image
      image.dispose
      render_target.dispose
      return dist_image
    end
  end
end


# テスト・コード
# クラス・ファイルの単体テスト
# 直接このファイルを走らせた場合に実行されるコード
if __FILE__ == $0

  Window.width = 800
  Window.height = 600

  Window.bgcolor = C_WHITE

  base_layer = Images.new((Window.width - 640) * 0.5, (Window.height - 480) * 0.5, 640, 480)
  base_layer.grid([5, 5], 2, C_BLUE)

  base_layer.string_pos("これらは\nテストの\nテキストです。", 40, 0, 0, C_RED)

  # base_layer.clear
  base_layer.width(320)
  base_layer.height(240)

  base_layer.angle = 5
  base_layer.color(C_GREEN)

  paint_layer = Images.new((Window.width - 640) * 0.5, (Window.height - 480) * 0.5, 640, 480, "", 0, C_DEFAULT)
  paint_layer.is_pen_active = true
  paint_layer.pen_size = 20

  paint_layer.frame(C_RED, 10)
  # paint_layer.alpha = 128
  # paint_layer.pen_color = [127, 127, 127, 127]
  paint_layer.pen_color = C_BLACK

  # canvas.is_pen_active = false

  Window.loop do

    base_layer.render
    paint_layer.update
    paint_layer.render

    # p paint_layer.get_paint_chart
  end
end
