#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

# color.rb Ver 1.0
# DxRubyの色関係汎用ライブラリ


module Color

=begin
  # DXRuby1.4.1以降で実装されているカラー定数
  C_BLACK   = [255,   0,   0,   0]
  C_RED     = [255, 255,   0,   0]
  C_GREEN   = [255,   0, 255,   0]
  C_BLUE    = [255,   0,   0, 255]
  C_YELLOW  = [255, 255, 255,   0]
  C_CYAN    = [255,   0, 255, 255]
  C_MAGENTA = [255, 255,   0, 255]
  C_WHITE   = [255, 255, 255, 255]
  C_DEFAULT = [  0,   0,   0,   0]
=end

  # 追加カラー定義
  C_IVORY = [222, 210, 191]
  C_GRAY = [128, 128, 128]
  C_MIKUSAN = [149, 237, 207]
  C_SHADOW = [64, 64, 64]
  C_ORANGE = [255, 122, 66]
  C_CREAM = [255, 255, 204]
  C_DARK_BLUE = [0, 0, 51]
  C_BROWN = [165, 42, 42]
  C_GOLD = [255, 215, 0]
  C_MISTY_ROSE = [255, 228, 225]
  C_PURPLE = [128, 0, 128]
  C_AQUAMARINE = [127, 255, 212]
  C_ROYAL_BLUE = [65, 105, 255]
end
