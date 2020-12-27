#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

# fonts.rb Ver 1.1
# ラベル作成用ライブラリ

require "dxruby"


class Fonts

  attr_accessor :x, :y, :string, :z, :color, :shadow, :shadow_color,
                :alpha, :angle, :edge, :edge_color, :edge_width, :edge_level, :name, :id, :target

  def initialize(x=0, y=0, string="", size=28, color=C_WHITE, option={})
    option = {:name=>"fonts", :id=>0, :target=>Window, :z=>0, :font_name=>"ＭＳ Ｐゴシック", :italic=>false, :weight=>400,
              :auto_fitting=>false, :alpha=>255, :angle=>0, :shadow=>true, :shadow_color=>[64, 64, 64],
              :edge=>false, :edge_color=>[0, 0, 0], :edge_width=>2, :edge_level=>4}.merge(option)

    @x = x
    @y = y
    @z = option[:z]
    @string = string
    @size = size
    @font_name = option[:font_name]
    @weight = option[:weight]
    @italic = option[:italic]
    @auto_fitting = option[:auto_fitting]
    @color = color
    @alpha = option[:alpha]
    @angle = option[:angle]
    @shadow = option[:shadow]
    @shadow_color = option[:shadow_color]
    @edge = option[:edge]
    @edge_color = option[:edge_color]
    @edge_width = option[:edge_width]
    @edge_level = option[:edge_level]
    @name = option[:name]
    @id = option[:id]
    @target = option[:target]
    self.constract
  end

  def constract
    @font.dispose if @font
    @font = Font.new(@size, @font_name, {:weight=>@weight, :italic=>@italic, :auto_fitting=>@auto_fitting})
  end

  # 各種セッター
  def set_pos(x, y)
    @x = x
    @y = y
  end

  def size=(size)
    @size = size
    self.constract
  end

  def font_name=(font_name)
    @font_name = font_name
    self.constract
  end

  def set_weight=(weight)
    @weight = weight
    self.constract
  end

  def set_italic=(italic)
    @italic = italic
    self.constract
  end

  def fit(width)
    @size = width / @string.split(//).size
    self.constract
  end

  # 各種ゲッター
  def width
    return @font.get_width(@string)
  end

  def height
    return @font.size
  end

  def draw
    @target.draw_font_ex(@x, @y, @string, @font, {:z=>@z, :color=>@color, :shadow=>@shadow, :shadow_color=>@shadow_color,
                                                    :alpha=>@alpha, :angle=>@angle, :edge=>@edge, :edge_color=>@edge_color,
                                                    :edge_width=>@edge_width, :edge_level=>@edge_level})
  end

  def vanish
    @font.dispose
  end
end


if __FILE__ == $0

  test_label = Fonts.new(0, 0, "FONTS")

  test_label.set_italic = true
  test_label.set_weight = 800
  test_label.fit(500)
  test_label.edge = true

  test_label.set_pos((Window.width - test_label.width) * 0.5, (Window.height - test_label.height) * 0.5)
  test_label.angle = 30

  Window.bgcolor = C_GREEN
  Window.loop do
    test_label.draw
  end
end
