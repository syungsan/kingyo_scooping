#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

# name_entry.rb Ver 1.1

require "dxruby"


class NameEntry

  if __FILE__ == $0
    require "../lib/dxruby/button"
  else
    require "./lib/dxruby/button"
  end

  HIRA_GANA = [["あ", "い", "う", "え", "お"],
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

  attr_accessor :x, :y, :id, :name, :target
  attr_reader :width, :height, :word_buttons

  def initialize(x, y, button_width=48, button_height=48, font_size=40, str_color=C_BLACK, base_color=C_WHITE, option={})
    option = {:id=>0, :name=>"name_entry", :target=>Window, :font_name=>"ＭＳ Ｐゴシック"}.merge(option)

    @words = HIRA_GANA

    @target = option[:target]
    @x = x
    @y = y
    @button_width = button_width
    @button_height = button_height
    @font_size = font_size
    @width = @words.size * @button_width
    @height = @words[0].size * @button_height
    @str_color = str_color
    @base_color = base_color
    @font_name = option[:font_name]

    @name = option[:name]
    @id = option[:id]
    @is_image_set = false

    self.make_keyboard
  end

  def make_keyboard

    @word_buttons = []
    for i in 0...@words.size
      for j in 0...@words[i].size

        if @words[i][j] != "" then

          # 隣接ボタンの間を1dot開けないとボタンを複数選択してしまう
          word_button = Button.new(@x + ((@button_width + 1) * i), @y + ((@button_height + 1) * j),
                                   @button_width, @button_height, @words[i][j], @font_size,
                                   {:color=>@base_color, :str_color=>@str_color, :font_name=>@font_name})

          if @is_image_set then
            image_clone = @image.clone
            word_button.set_image(image_clone)
          end

          @word_buttons << word_button
        end
      end
    end
  end

  def set_pos(x, y)
    self.x = x
    self.y = y
    self.make_keyboard
  end

  def set_image(image)
    @is_image_set = true
    @image = image
    self.make_keyboard
  end

  def update
  end

  def draw
    for word_button in @word_buttons do
      word_button.draw
    end
  end

  def vanish

  end
end


if __FILE__ == $0

  Window.width = 1280
  Window.height = 720

  name_entry = NameEntry.new(0, 0, 70, 70, 54, C_BLACK, C_WHITE)
  name_entry.set_pos((Window.width - name_entry.width) * 0.5, (Window.height - name_entry.height) * 0.5)

  Window.loop do
    for word_button in name_entry.word_buttons do
      if word_button.pushed? then
        p word_button.string
      end
    end
    name_entry.draw
  end
end