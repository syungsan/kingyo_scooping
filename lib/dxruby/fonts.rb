#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

# fonts.rb Ver 1.0
# ラベル作成用ライブラリ

require "dxruby"


class Fonts

  attr_accessor :x, :y, :id, :name, :string, :st_color, :isShadow, :target

  def initialize(x=0, y=0, string="", font_size=28, st_color=C_WHITE, id=0, name="Fonts", option={})
    option = {:isShadow=>true, :target=>Window, :fontType=>"ＭＳ Ｐゴシック", :isItalic=>false, :isBold=>false}.merge(option)

    self.target = option[:target]
    self.x = x
    self.y = y
    self.id = id
    self.name = name
    self.string = string
    self.st_color = st_color
    self.isShadow = option[:isShadow]
    @font_size = font_size
    @fontType = option[:fontType]
    @isItalic = option[:isItalic]
    @isBold = option[:isBold]

    @font = nil
    self.build
  end

  # 各種セッター
  def set_pos(x, y)
    self.x, self.y = x, y
  end

  def font_size=(size)
    @font_size = size
    self.build
  end

  def fontType=(type)
    @fontType = type
    self.build
  end

  def isBold=(isBold)
    @isBold = isBold
    self.build
  end

  def isItalic=(isItalic)
    @isItalic = isItalic
    self.build
  end

  def fit(width)
    @font_size = width / self.string.split(//).size
    self.build
  end

  # 各種ゲッター
  def get_width
    return @font.getWidth(self.string)
  end

  def get_height
    return @font.size
  end

  def set_z(z)
    @z = z
  end

  def build
    @font.dispose if !@font.nil?
    @font = Font.new(@font_size, @fontType, {:weight=>@isBold, :italic=>@isItalic})
  end

  def render
    self.target.drawFontEx(self.x, self.y, self.string, @font, {:z=>@z, :color=>self.st_color, :shadow=>self.isShadow, :shadow_color=>[64, 64, 64]})
  end
end


if __FILE__ == $0

  testLabel = Fonts.new(0, 0, "FONTS")

  testLabel.isItalic = true
  testLabel.isBold = true

  testLabel.fit(300)

  Window.loop do
    testLa
  end
end
