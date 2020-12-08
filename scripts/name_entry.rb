#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

# name_entry.rb Ver 1.0

require "dxruby"

if __FILE__ == $0
  Dir.chdir("#{Dir.pwd}/../")
  require "./lib/dxruby/button"
end


class NameEntry

  KANA = [["あ", "い", "う", "え", "お"],
          ["か", "き", "く", "け", "こ"],
          ["さ", "し", "す", "せ", "そ"],
          ["た", "ち", "つ", "て", "と"],
          ["な", "に", "ぬ", "ね", "の"],
          ["は", "ひ", "ふ", "へ", "ほ"],
          ["ま", "み", "む", "め", "も"],
          ["や", "", "ゆ", "", "よ"],
          ["ら", "り", "る", "れ", "ろ"],
          ["わ", "", "を", "", "ん"],
          ["ゃ", "", "ゅ", "", "ょ"],
          ["", "", "っ", "", "ー"],
          ["が", "ぎ", "ぐ", "げ", "ご"],
          ["ざ", "じ", "ず", "ぜ", "ぞ"],
          ["だ", "ぢ", "づ", "で", "ど"],
          ["ば", "び", "ぶ", "べ", "ぼ"],
          ["ぱ", "ぴ", "ぷ", "ぺ", "ぽ"]]

  attr_accessor :x, :y, :name, :id, :target
  attr_reader :width, :height, :kanaButtons

  def initialize(x, y, buttonWidth=48, buttonHeight=48, fontSize=40, strColor=C_BLACK, baseColor=C_WHITE, option={})
    option = {:id=>0, :name=>"NameEntry", :target=>Window, :fontType=>"ＭＳ Ｐゴシック"}.merge(option)

    self.target = option[:target]
    self.x = x
    self.y = y
    @buttonWidth = buttonWidth
    @buttonHeight = buttonHeight
    @fontSize = fontSize
    @width = KANA.size * @buttonWidth
    @height = KANA[0].size * @buttonHeight
    @strColor = strColor
    @baseColor = baseColor
    @fontType = option[:fontType]
    self.name = name
    self.id = id
    @isImageSet = false

    self.makeKeyboard
  end

  def makeKeyboard

    @kanaButtons = []
    for i in 0...KANA.size
      for j in 0...KANA[i].size

        if KANA[i][j] != "" then

          # 隣接ボタンの間を1dot開けないとボタンを複数選択してしまう
          kanaButton = Button.new(self.x + ((@buttonWidth + 1) * i), self.y + ((@buttonHeight + 1) * j), @buttonWidth, @buttonHeight, KANA[i][j], @fontSize)

          if @isImageSet then
            kanaButton.image(@filename)
            kanaButton.set_pos(self.x + ((kanaButton.w + 1) * i), self.y + ((kanaButton.h + 1) * j))
          end

          kanaButton.color(@baseColor)
          kanaButton.font_color(@strColor)
          kanaButton.fontType = @fontType

          @kanaButtons << kanaButton
        end
      end
    end
  end

  def setPos(x, y)
    self.x, self.y = x, y
    self.makeKeyboard
  end

  def setImage(filename)
    @isImageSet = true
    @filename = filename
    self.makeKeyboard
  end

  def update
  end

  def draw
    for kanaButton in @kanaButtons do
      kanaButton.render
    end
  end
end


if __FILE__ == $0

  Window.width = 1280
  Window.height = 720

  nameEntry = NameEntry.new(0, 0, 70, 70, 54, C_BLACK, C_WHITE)
  nameEntry.setPos((Window.width - nameEntry.width) * 0.5, (Window.height - nameEntry.height) * 0.5)

  Window.loop do
    for kanaButton in nameEntry.kanaButtons do
      if kanaButton.pushed? then
        p kanaButton.text
      end
    end
    nameEntry.draw
  end
end