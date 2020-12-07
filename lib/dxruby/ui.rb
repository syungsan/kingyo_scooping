#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

# ui.rb Ver 0.8
# ボタン作成用ライブラリ

require "dxruby"


class RadioButton

  attr_accessor :x, :y, :id, :name, :target
  attr_reader :size

  def initialize(x, y, id=0, size=20, markColor=C_BLACK, innerColor=C_WHITE, frameColor=C_BLACK, option={})
    option = {:id=>0, :name=>"RadioButton", :markSize=>6, :frameSize=>2, :target=>Window}.merge(option)

    self.target = option[:target]
    self.x = x
    self.y = y
    @size = size
    self.name = option[:name]
    self.id = id

    @markColor = markColor
    @innerColor = innerColor
    @frameColor = frameColor
    @markSize = option[:markSize]
    @frameSize = option[:frameSize]

    @isCheck = false
    self.constract
  end

  def constract
    @image.dispose if @image and !@image.disposed?
    @image = Image.new(@size, @size, C_DEFAULT)

    @image.circleFill(@size * 0.5, @size * 0.5, size * 0.5, @frameColor)
    @image.circleFill(@size * 0.5, @size * 0.5, size * 0.5 - @frameSize, @innerColor)
  end

  def setCheck(bool)
    if bool then
      unless @isCheck then
        @image.circleFill(@size * 0.5, @size * 0.5, @markSize, @markColor)
        @isCheck = true
      end
    elsif @isCheck
      @isCheck = false
      self.constract
    end
  end

  #描画位置の設定
  def setPos(x, y)
    self.x, self.y = x, y
  end

  def draw
    self.target.drawEx(self.x, self.y, @image)
  end

  #ボタンを押下した時の処理
  def checked?
    mouseX = Input.mousePosX
    mouseY = Input.mousePosY

    if Input.mousePush?(M_LBUTTON) and !@isCheck then
      if mouseX >= self.x and mouseX <= self.x + @size and mouseY >= self.y and mouseY <= self.y + @size then

        self.setCheck(true)
        @isCheck = true
        return true
      end
    end
    return false
  end
end


# 角の丸い四角形を描画
class Image

  def roundbox(x1, y1, x2, y2, r, c)
    image = Image.new(r * 2, r * 2).circle(r, r, r, c)
    self.draw(x1, y1, image, 0, 0, r, r)
    self.draw(x2 - r, y1, image, r, 0, r, r)
    self.draw(x1, y2 - r, image, 0, r, r, r)
    self.draw(x2 - r, y2 - r, image, r, r, r, r)
    self.line(x1 + r, y1, x2 - r, y1, c)
    self.line(x2, y1 + r, x2, y2 - r, c)
    self.line(x2 - r, y2, x1 + r, y2, c)
    self.line(x1, y1 + r, x1, y2 - r, c)
    image.dispose
    self
  end

  def roundbox_fill(x1, y1, x2, y2, r, c)
    image = Image.new(r * 2, r * 2).circle_fill(r, r, r, c)
    self.draw(x1, y1, image, 0, 0, r, r)
    self.draw(x2 - r, y1, image, r, 0, r, r)
    self.draw(x1, y2 - r, image, 0, r, r, r)
    self.draw(x2 - r, y2 - r, image, r, r, r, r)
    self.box_fill(x1 + r, y1, x2 - r, y2, c)
    self.box_fill(x1, y1 + r, x2, y2 - r, c)
    image.dispose
    self
  end
end


if __FILE__ == $0

  Window.bgcolor = C_WHITE

  radioButtons = []
  4.times do |index|
    radioButtons << RadioButton.new(300, 200 + (50 * index), index)
  end
  radioButtons[0].setCheck(true)

  Window.loop do

    # ラジオボタンの排他処理 ##########
    checkID = nil
    for radioButton in radioButtons do
      if radioButton.checked? then
        checkID = radioButton.id

        case checkID
        when 0 then
          # Enter your code...
        end
      end
    end

    if checkID then
      for radioButton in radioButtons do
        unless radioButton.id == checkID then
          radioButton.setCheck(false)
        end
      end
    end
    ###################################

    for radioButton in radioButtons do
      radioButton.draw
    end
  end
end
