#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

# button.rb Ver 1.0
# ボタン作成用ライブラリ

require "dxruby"


class Button

  attr_accessor :x, :y, :name, :id, :target, :scaleX, :scaleY, :angle
  attr_reader :w, :h, :text

  def initialize(x, y, w=100, h=40, string="", font_size=36, color=[120, 120, 120], str_color=[255, 255, 255], gr_color1=[220, 220, 220], gr_color2=[70, 70, 70], id=0, name="Button", option={})
    option = {:target=>Window, :fontType=>"ＭＳ Ｐゴシック", :isHover=>true}.merge(option)

    self.target = option[:target]
    self.x = x
    self.y = y
    @w = w
    @h = h
    self.name = name
    self.id = id
    @color = color
    @frameColor = [gr_color1, gr_color2]
    @images = []
    self.construct
    @image = @images[0]
    @text = string
    @font_size = font_size
    @str_color = str_color
    @fontType = option[:fontType]
    self.drawString
    @scaleX = 1.0
    @sclleY = 1.0
    @angle = 0.0
    @click = false
    @isImageSet = false
    @isHover = option[:isHover]
  end

  #描画位置の設定
  def set_pos(x, y)
    self.x, self.y = x, y
  end

  def color(color)
    @color = color
    self.construct
    @image = @images[0]
    self.drawString
  end

  def image(filename, scaleX=1.0, scaleY=1.0, angle=0)
    @filename = filename
    @scaleX = scaleX
    @scaleY = scaleY
    @angle = angle
    @isImageSet = true
    self.construct
    self.drawString
  end

  def construct

    if !@images.empty? then
      for image in @images
        image.dispose if image and !image.disposed?
      end
      @images = []
    end

    unless @isImageSet then
      2.times do
        image = Image.new(@w, @h, @color)
        image.boxFill(0, 0, @w, 2, @frameColor[0])
        image.boxFill(0, 0, 2, @h, @frameColor[0])
        image.boxFill(@w - 2, 0, @w, @h, @frameColor[1])
        image.boxFill(0, @h - 2, @w, @h, @frameColor[1])
        @images << image
        @frameColor.reverse!
      end
    else
      image = Image.load(@filename)

      @w = image.width
      @h = image.height

      @images << image

      if @isHover then
        @images << image.change_hls(0, -20, 0)
        @images << image.change_hls(0, 20, 0)
      end
    end
    @image = @images[0]
  end

  def string(string, font_size)
    @font_size = font_size
    @text = string
    self.construct
    self.drawString
  end

  def font_color(font_color)
    @str_color = font_color
    self.construct
    self.drawString
  end

  def fontType=(fontType)
    @fontType = fontType
    self.construct
    self.drawString
  end

  def isHover=(isHover)
    @isHover = isHover
    self.construct
    self.drawString
  end

  def frame(color, frame_size=1)
    @image.box_fill(0, 0, @w, frame_size - 1, color) # 上辺
    @image.box_fill(0, 0, frame_size - 1, @h, color) # 左辺
    @image.box_fill(@w - frame_size, 0, @w, @h, color) # 右辺
    @image.box_fill(0, @h - frame_size, @w, @h, color) # 左辺
  end

  def drawString
    if @text != "" then
      @font = Font.new(@font_size, @fontType)
      stringWidth = @font.getWidth(@text)
      @images.size.times do |i|
        @images[i].drawFont((@w - stringWidth) * 0.5, (@h - @font.size) * 0.5, @text, @font, @str_color)
      end
    end
  end

  def render
    self.target.drawEx(self.x, self.y, @image, {:scale_x=>@scaleX, :scale_y=>@scaleY, :angle=>@angle})
  end

  def scale_render(sx, sy)
    self.target.draw_scale(self.x, self.y, @image, sx, sy, 0, 0)
  end

  def rot_render(angle)
    self.target.drawRot(self.x, self.y, @image, angle)
  end

  # 押下しているかの判定
  def pushing?
    mouseX = Input.mousePosX
    mouseY = Input.mousePosY

    if Input.mouseDown?(M_LBUTTON) and mouseX >= self.x and mouseX <= self.x + @w and mouseY >= self.y and mouseY <= self.y + @h then
      return true
    else
      return false
    end
  end

  #ボタンを押下した時の処理
  def pushed?
    mouseX = Input.mousePosX
    mouseY = Input.mousePosY

    if @isHover then
      if mouseX >= self.x and mouseX <= self.x + @w and mouseY >= self.y and mouseY <= self.y + @h and @isImageSet and !@click then
        @image = @images[2]
      elsif !@click
        @image = @images[0]
      end
    end

    if Input.mousePush?(M_LBUTTON) and !@click then
      if mouseX >= self.x and mouseX <= self.x + @w and mouseY >= self.y and mouseY <= self.y + @h then

        @image = @images[1] if @images[1]

        @click = true
        return false
      end

    elsif !Input.mouseDown?(M_LBUTTON) and @click then

      @image = @images[0]

      @click = false
      return true if mouseX >= self.x and mouseX <= self.x + @w and mouseY >= self.y and mouseY <= self.y + @h
    else
      return false
    end
  end

  def hovered?
    mouseX = Input.mousePosX
    mouseY = Input.mousePosY

    if mouseX >= self.x and mouseX <= self.x + @w and mouseY >= self.y and mouseY <= self.y + @h and @isImageSet and !@click then
      return true
    else
      return false
    end
  end
end


if __FILE__ == $0

  button = Button.new(300, 300, 100, 40, "BUTTON")
  button.color(C_BLUE)
  button.font_color(C_RED)
  button.string("OK", 42)

  p button.w

  # button.image("sample.png", 0.5, 0.5, 20)
  # button.string = ("BAD", 30)
  button.angle = 45

  button.frame(C_WHITE, 10)

  Window.loop do
    button.render
    if button.pushed? then
      p "pushed!"
    end
  end
end
