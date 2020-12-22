#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

# images.rb Ver 1.1
# 汎用描画ライブラリ

require "dxruby"


class Images

  attr_accessor :x, :y, :id, :name, :isPenActive, :penSize, :penColor, :isInnovativeLine, :isLegacyLine, :target, :scaleX, :scaleY, :angle, :alpha
  attr_reader :w, :h, :text, :font_size

  def initialize(x=0, y=0, w=50, h=40, string= "", font_size=28, color=C_WHITE, st_color=C_BLACK, id=0, name="Images", option={})
    option = {:fontType=>"ＭＳ Ｐゴシック", :isPenActive=>false, :penSize=>5, :penColor=>C_BLACK, :isInnovativeLine=>true, :isLegacyLine=>false, :target=>Window}.merge(option)

    self.target = option[:target]
    self.x = x
    self.y = y
    @filename = nil
    @copyName = nil
    @stretch_filename = nil
    @w = w
    @h = h
    @color = color
    @font_size = font_size
    @st_color = st_color
    @fontType = option[:fontType]
    @text = string
    @stringPos = []
    self.construct
    self.name = name
    self.id = id
    self.isPenActive = option[:isPenActive]
    self.penSize = option[:penSize]
    self.penColor = option[:penColor]
    self.isInnovativeLine = option[:isInnovativeLine]
    self.isLegacyLine = option[:isLegacyLine]

    @curX, @curY = nil,
    @isPaint = false
    @isGrid = false
    @isFrame = false
  end

  def set_pos(x, y)
    self.x, self.y = x, y
  end

  def construct

    @image.dispose if @image and !@image.disposed?
    @image = Image.new(@w, @h, @color)

    self.setImage if @filename or @copyName
    self.set_stretch_image if @stretch_filename

    self.grid(@divisionNumbers, @gridLineWidth, @gridLineColor) if @isGrid
    self.frame(@frameColor, @frameSize) if @isFrame
    self.drawString if @text != ""
  end

  def string(string, font_size=28, st_color=C_BLACK)
    @text = string
    @font_size = font_size
    @st_color = st_color
    self.construct
  end

  def string=(string)
    @text = string
    self.construct
  end

  def string_pos(string, font_size, x, y, color)
    @text = string
    @font_size = font_size
    @st_color = color
    @stringPos = [x, y]
    self.construct
  end

  def fontSize=(fontSize)
    @font_size = fontSize
    self.construct
  end

  def font_color=(fontColor)
    @st_color = fontColor
    self.construct
  end

  def fontType=(fontType)
    @fontType = fontType
    self.construct
  end

  def drawString

    @font = Font.new(@font_size, @fontType)

    if @text.include?("\n") then
      strings = @text.split("\n")

      for loopID in 0...strings.size do

        if !@stringPos.empty? then
          @image.drawFont(@stringPos[0], @stringPos[1] + @font.size * loopID, strings[loopID], @font, @st_color)
        else
          stringWidth = @font.getWidth(strings[loopID])
          @image.drawFont((@w - stringWidth) * 0.5, (@h - (@font.size * strings.size)) * 0.5 + @font.size * loopID, strings[loopID], @font, @st_color)
        end
      end
    else
      if !@stringPos.empty? then
        @image.drawFont(@stringPos[0], @stringPos[1], @text, @font, @st_color)
      else
        stringWidth = @font.getWidth(@text)
        @image.drawFont((@w - stringWidth) * 0.5, (@h - @font.size) * 0.5, @text, @font, @st_color)
      end
    end
  end

  def image(filename)
    @filename = filename
    self.construct
  end

  def setImage
    image = Image.load(@filename) if @filename
    image = @copyName if @copyName
    @w = image.width
    @h = image.height
    @image = image
  end

  def stretch_image(width, height, stretch_filename)
    @stretch_filename = stretch_filename
    @w = width
    @h = height
    self.construct
  end

  def set_stretch_image
    image = Image.load(@stretch_filename)
    @image = RenderTarget.new(@w, @h).draw_scale(0, 0, image, @w / image.width.to_f, @h / image.height.to_f, 0, 0).update.to_image
  end

  def getImage
    return @image
  end

  def copyImage(copyName)
    @copyName = copyName
    self.construct
  end

  def frame(frameColor=C_BLACK, frameSize=2)

    @frameColor = frameColor
    @frameSize = frameSize
    @isFrame = true

    @image.box_fill(0, 0, @w,  @frameSize - 1, @frameColor) # 上辺
    @image.box_fill(0, 0, @frameSize - 1 , @h, @frameColor) # 左辺
    @image.box_fill(@w - @frameSize, 0, @w , @h, @frameColor) # 右辺
    @image.box_fill(0, @h - @frameSize, @w , @h, @frameColor) # 左辺
  end

  def update
    self.pen if self.isPenActive
  end

  def pen

    oldX, oldY = @curX, @curY
    @curX, @curY = Input.mouse_pos_x - self.x, Input.mouse_pos_y - self.y

    # ボタンを押している間の処理
    if Input.mouse_down?(M_LBUTTON) then

      # エッジに円を描画
      @image.circleFill(@curX, @curY, self.penSize, self.penColor) unless @isPaint
      @isPaint = true
      @image.circleFill(@curX, @curY, self.penSize, self.penColor) if self.isLegacyLine

      if self.isInnovativeLine then

        # 円形ペン描画（勝又スペシャル）###################################################
        # line数が多いので割とカクつく
        for i in 0...360 do # 回転角度θをi
          for j in self.penSize-1..self.penSize do # 円の厚み0からに指定で中実円 かすれない程度に厚く
            @image.line(@curX+j*Math.cos(i*Math::PI/180), @curY+j*Math.sin(i*Math::PI/180),
                       oldX+j*Math.cos(i*Math::PI/180),oldY+j*Math.sin(i*Math::PI/180),self.penColor)  # i*j本の線を描画
          end
        end
        # image.circleFill(@curX, @curY, 10, self.penColor) # jが0からなら要らない書き出しの塗りつぶし用（line数削減で負荷軽減用）
      end

      if self.isLegacyLine then

        for loopID in 0...self.penSize do

          # エッジの回転アリ（多々納スペシャル）##########################
          theta = Math.atan2(@curY - oldY, @curX - oldX)

          curRX = loopID * Math.cos((Math::PI * 0.5) + theta) + @curX
          curRY = loopID * Math.sin((Math::PI * 0.5) + theta) + @curY

          oldRX = loopID * Math.cos((Math::PI * 0.5) + theta) + oldX
          oldRY = loopID * Math.sin((Math::PI * 0.5) + theta) + oldY

          # 反対側も
          curLX = loopID * Math.cos(-1 * (Math::PI * 0.5) + theta) + @curX
          curLY = loopID * Math.sin(-1 * (Math::PI * 0.5) + theta) + @curY

          oldLX = loopID * Math.cos(-1 * (Math::PI * 0.5) + theta) + oldX
          oldLY = loopID * Math.sin(-1 * (Math::PI * 0.5) + theta) + oldY

          @image.line(curLX, curLY, oldLX, oldLY, self.penColor)
          @image.line(curRX, curRY, oldRX, oldRY, self.penColor)

          # エッジの回転ナシ（荒木スペシャル）############################
          new_right_x = @curX + loopID
          new_left_x = @curX - loopID
          new_zero_y = @curY

          old_right_x = oldX + loopID
          old_left_x = oldX - loopID
          old_zero_y = oldY

          new_up_y = @curY - loopID
          new_down_y = @curY + loopID
          new_zero_x = @curX

          old_up_y = oldY - loopID
          old_down_y = oldY + loopID
          old_zero_x = oldX

          @image.line(new_right_x, new_zero_y, old_right_x, old_zero_y, self.penColor)
          @image.line(new_left_x, new_zero_y, old_left_x, old_zero_y, self.penColor)
          @image.line(new_zero_x, new_up_y, old_zero_x, old_up_y, self.penColor)
          @image.line(new_zero_x, new_down_y, old_zero_x, old_down_y, self.penColor)
        end
      end
    else
      @isPaint = false
    end
  end

  def getPaintChart
    if self.isPenActive then
      if @isPaint then
        if @curX >= 0 and @curX <= @w and @curY >= 0 and @curY <= @h then
          chart = [@curX, @curY]
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

  def grid(divisionNumbers, gridLineWidth, gridLineColor)

    @isGrid = true

    @divisionNumbers = divisionNumbers
    @gridLineWidth = gridLineWidth
    @gridLineColor = gridLineColor

    (@divisionNumbers[0] + 1).times do |loopID|
      @image.box_fill(0, (@h - @gridLineWidth) / @divisionNumbers[0] * loopID, @w, ((@h - @gridLineWidth) / @divisionNumbers[0] * loopID) + @gridLineWidth, @gridLineColor)
    end
    (@divisionNumbers[1] + 1).times do |loopID|
      @image.box_fill((@w - @gridLineWidth) / @divisionNumbers[1] * loopID, 0, ((@w - @gridLineWidth) / @divisionNumbers[1] * loopID) + @gridLineWidth, @h, @gridLineColor)
    end
  end

  def clear
    @image.dispose if @image
    @filename = nil if !@filename.nil?
    @text = "" if @text != ""
    @isPaint = false
    @isGrid = false
    @isFrame = false
    self.construct
  end

  def width(width)
    @w = width
    self.construct
  end

  def height(height)
    @h = height
    self.construct
  end

  def color(color)
    @color = color
    self.construct
  end

  def save(filePath)
    @image.save(filePath)
  end

  def render
    self.target.drawEx(self.x, self.y, @image, {:scale_x=>self.scaleX, :scale_y=>self.scaleY, :angle=>self.angle, :alpha=>self.alpha})
  end

  def scale_render(sx,sy)
    self.target.draw_scale(self.x, self.y, @image, sx, sy, 0, 0)
  end

  def alpha_render(alpha)
    self.target.drawAlpha(self.x, self.y, @image, alpha)
  end

  def rot_render(angle)
    self.target.drawRot(self.x, self.y, @image, angle)
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

  baseLayer = Images.new((Window.width - 640) * 0.5, (Window.height - 480) * 0.5, 640, 480)
  baseLayer.grid([5, 5], 2, C_BLUE)

  baseLayer.string_pos("これらは\nテストの\nテキストです。", 40, 0, 0, C_RED)

  # baseLayer.clear
  baseLayer.width(320)
  baseLayer.height(240)

  baseLayer.angle = 5
  baseLayer.color(C_GREEN)

  paintLayer = Images.new((Window.width - 640) * 0.5, (Window.height - 480) * 0.5, 640, 480, "", 0, C_DEFAULT)
  paintLayer.isPenActive = true
  paintLayer.penSize = 20

  paintLayer.frame(C_RED, 10)
  # paintLayer.alpha = 128
  # paintLayer.penColor = [127, 127, 127, 127]
  paintLayer.penColor = C_BLACK

  # canvas.isPenActive = false

  Window.loop do

    baseLayer.render
    paintLayer.update
    paintLayer.render

    # p paintLayer.getPaintChart
  end
end
