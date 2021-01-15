#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

# button.rb Ver 1.0
# ボタン作成用ライブラリ

require "dxruby"


class Button

  attr_accessor :x, :y, :alpha, :angle, :scale_x, :scale_y, :z,
                :name, :id, :target, :add_push, :is_enable
  attr_reader :width, :height, :string, :is_hoverable

  def initialize(x=0, y=0, width=100, height=40, string="", font_size=36, option={})
    option = {:color=>[120 ,120, 120], :str_color=>[255, 255, 255], :font_name=>"ＭＳ Ｐゴシック",
              :gr_color1=>[220, 220, 220], :gr_color2=>[70, 70, 70], :is_hoverable=>true, :scale_x=>1, :scale_y=>1,
              :alpha=>255, :angle=>0, :z=>0, :str_weight=>400, :str_italic=>false, :str_auto_fitting=>false,
              :str_shadow=>false, :str_shadow_color=>[0, 0, 0], :str_alpha=>0, :str_angle=>0, :str_edge=>false,
              :str_edge_color=>[0, 0, 0], :str_edge_width=>2, :str_edge_level=>4, :name=>"button", :id=>0,
              :target=>Window}.merge(option)

    @x = x
    @y = y
    @z = option[:z]
    @width = width
    @height = height
    @string = string
    @font_size = font_size
    @color = option[:color]
    @str_color = option[:str_color]
    @font_name = option[:font_name]
    @frame_color = [option[:gr_color1], option[:gr_color2]]
    @scale_x = option[:scale_x]
    @scale_y = option[:scale_y]
    @alpha = option[:alpha]
    @angle = option[:angle]
    @is_hoverable = option[:is_hoverable]
    @name = option[:name]
    @id = option[:id]
    @target = option[:target]
    @images = []

    @str_weight = option[:weight]
    @str_italic = option[:italic]
    @str_auto_fitting = option[:auto_fitting]
    @str_shadow = option[:shadow]
    @str_shadow_color = option[:shadow_color]
    @str_alpha = option[:alpha]
    @str_angle = option[:angle]
    @str_edge = option[:edge]
    @str_edge_color = option[:edge_color]
    @str_edge_width = option[:edge_width]
    @str_edge_level = option[:edge_level]

    @has_image_set = false
    @is_click = false
    @is_enable = true
    @response_count = 0

    self.construct
    self.draw_string
  end

  def construct

    unless @images.empty? then
      @images.each do |image|
        image.clear
      end
      @images.clear
    end

    2.times do
      image = Image.new(@width, @height, @color)
      image.boxFill(0, 0, @width, 2, @frame_color[0])
      image.boxFill(0, 0, 2, @height, @frame_color[0])
      image.boxFill(@width - 2, 0, @width, @height, @frame_color[1])
      image.boxFill(0, @height - 2, @width, @height, @frame_color[1])
      @images.push(image)
      @frame_color.reverse!
    end
    @image = @images[0]
  end

  def draw_string

    unless @string == "" then
      font = Font.new(@font_size, @font_name,
                      {:weight=>@str_weight, :italic=>@str_italic, :auto_fitting=>@str_auto_fitting})
      string_width = font.get_width(@string)
      @images.each do |image|
        image.draw_font_ex((@width - string_width) * 0.5, (@height - font.size) * 0.5, @string, font,
                           {:color=>@str_color, :shadow=>@str_shadow, :shadow_color=>@str_shadow_color,
                            :alpha=>@str_alpha, :angle=>@str_angle, :edge=>@str_edge, :edge_color=>@str_edge_color,
                            :edge_width=>@str_edge_width, :edge_level=>@str_edge_level})
      end
      font.dispose
    end
  end

  #描画位置の設定
  def set_pos(x, y)
    @x = x
    @y = y
  end

  def set_string(string, font_size=36, font_name="ＭＳ Ｐゴシック", option={})
    option = {:weight=>400, :italic=>false, :auto_fitting=>false, :color=>[255, 255, 255], :shadow=>false,
              :shadow_color=>[0, 0, 0], :alpha=>0, :angle=>0, :edge=>false, :edge_color=>[0, 0, 0], :edge_width=>2,
              :edge_level=>4}.merge(option)

    @string = string
    @font_size = font_size
    @font_name = font_name
    @str_color = option[:color]
    @str_weight = option[:weight]
    @str_italic = option[:italic]
    @str_auto_fitting = option[:auto_fitting]
    @str_shadow = option[:shadow]
    @str_shadow_color = option[:shadow_color]
    @str_alpha = option[:alpha]
    @str_angle = option[:angle]
    @str_edge = option[:edge]
    @str_edge_color = option[:edge_color]
    @str_edge_width = option[:edge_width]
    @str_edge_level = option[:edge_level]

    unless @has_image_set then
      self.construct
    else
      self.image_reconstract
    end
    self.draw_string
  end

  def string=(string)

    @string = string
    unless @has_image_set then
      self.construct
    else
      self.image_reconstract
    end

    self.draw_string
  end

  def color=(color)
    unless @has_image_set then
      @color = color
      self.construct
      self.draw_string
    end
  end

  def font_color=(font_color)

    @str_color = font_color
    unless @has_image_set then
      self.construct
    else
      self.image_reconstract
    end

    self.draw_string
  end

  def font_name=(font_name)

    @font_name= font_name
    unless @has_image_set then
      self.construct
    else
      self.image_reconstract
    end

    self.draw_string
  end

  def image_reconstract

    unless @images.empty? then
      @images.each do |image|
        image.clear
      end
      @images.clear
    end

    @org_images.each do |org_image|
      @images.push(org_image.clone)
    end

    if @is_hoverable and @images.size <= 1 then
      @images.push(@images[0].change_hls(0, -20, 0))
      @images.push(@images[0].change_hls(0, 20, 0))
      @images.push(@images[0].change_hls(0, 35, -35))
    end

    if @is_enable then
      @image = @images[0]
    else
      @image = @images[3]
    end
    @has_image_set = true
  end

  def set_image(image)

    @width = image.width
    @height = image.height

    unless @images.empty? then
      @images.each do |old_image|
        old_image.clear
      end
      @images.clear
    end

    @images.push(image)
    if @is_hoverable then
      @images.push(image.change_hls(0, -20, 0))
      @images.push(image.change_hls(0, 20, 0))
      @images.push(image.change_hls(0, 35, -35))
    end

    @org_images = []
    @images.each do |image|
      @org_images.push(image.clone)
    end
    @image = @images[0]

    @has_image_set = true
    self.draw_string
  end

  def hover=(is_hoverable)
    if @has_image_set then
      @is_hoverable = is_hoverable
      self.image_reconstract
      self.draw_string
    end
  end

  def frame(color, frame_size=1)

    unless @has_image_set then
      self.construct
    else
      self.image_reconstract
    end
    @image.box_fill(0, 0, @width, frame_size - 1, color) # 上辺
    @image.box_fill(0, 0, frame_size - 1, @height, color) # 左辺
    @image.box_fill(@width - frame_size, 0, @width, @height, color) # 右辺
    @image.box_fill(0, @height - frame_size, @width, @height, color) # 左辺

    self.draw_string
  end

  # 押下しているかの判定
  def pushing?

    mouse_x = Input.mouse_pos_x
    mouse_y = Input.mouse_pos_y

    if Input.mouse_release?(M_LBUTTON) and mouse_x >= @x and mouse_x <= @x + @width and
      mouse_y >= @y and mouse_y <= @y + @height then
      return true

    elsif Input.mouse_down?(M_LBUTTON) and mouse_x >= @x and mouse_x <= @x + @width and
      mouse_y >= @y and mouse_y <= @y + @height then

      if @response_count >= 15 then
        @response_count = 0
        return true
      else
        @response_count += 1
        return false
      end
    else
      @response_count = 0 unless @response_count == 0
      return false
    end
  end

  #ボタンを押下した時の処理
  def pushed?

    mouse_x = Input.mouse_pos_x
    mouse_y = Input.mouse_pos_y

    if Input.mouse_push?(M_LBUTTON) and not @is_click and @is_enable then
      if mouse_x >= @x and mouse_x <= @x + @width and mouse_y >= @y and mouse_y <= @y + @height then

        @image = @images[1] if @images[1]

        @is_click = true
        return false
      end

    elsif not Input.mouse_down?(M_LBUTTON) and @is_click and @is_enable then

      @image = @images[0] if @images[0]

      @is_click = false
      return true if mouse_x >= @x and mouse_x <= @x + @width and mouse_y >= @y and mouse_y <= @y + @height
    else
      return false
    end
  end

  def hovered?

    mouse_x = Input.mouse_pos_x
    mouse_y = Input.mouse_pos_y

    if mouse_x >= @x and mouse_x <= @x + @width and mouse_y >= @y and mouse_y <= @y + @height and
      @has_image_set and not @is_click and @is_hoverable and @is_enable then

      @image = @images[2] if @images[2]
      return true

    elsif not @is_click
      @image = @images[0] if @images[0]
      return false
    end
  end

  def enable=(is_enable)
    @is_enable = is_enable
    if @is_enable then
      @image = @images[0]
      @is_click = false
    else
      @image = @images[3]
      @is_click = true
    end
  end

  def blink
    if @image == @images[2] then
      @image = @images[0]
    else
      @image = @images[2]
    end
  end

  def draw
    @target.draw_ex(@x, @y, @image, {:scale_x=>@scale_x, :scale_y=>@scale_y, :alpha=>@alpha, :angle=>@angle, :z=>@z})
  end

  def vanish
    unless @images.empty then
      @images.each do |image|
        image.clear
        image.dispose unless image.disposed?
      end
      @images.clear
    end
  end
end


if __FILE__ == $0

  button = Button.new(0, 0, 300, 100, "テストボタン", font_size=54)
  button.set_pos((Window.width - button.width) * 0.5, (Window.height - button.height) * 0.5)

  button.set_string("交換しました", 24)
  button.color = C_BLUE
  button.font_color = C_RED
  button.angle = 30

  image = Image.load("../../images/m_1.png")
  button.set_image(image)
  # button.frame(C_WHITE, 10)
  # button.hover = false

  Window.loop do
    button.draw
    if button.pushed? then
      p "pushed!"
    end
    button.hovered?
  end
end
