#!ruby -Ku
# -*- mode: ruby; coding: utf-8 -*-
# Last updated: <2016/03/14 19:45:20 +0900>
#
# イージングのテスト

require 'dxruby'


module Easing

  # quadratic ease in out
  # @param t [Number] 時間(0.0 - 1.0)
  # @param b [Number] 基準値
  # @param c [Number] 変化量
  # @param d [Number] 1.0
  # @return [Number] 結果

  def ease_in_out_quad(t, b, c, d)
    t /= (d / 2.0)
    return (c / 2.0 * t * t + b) if t < 1.0
    t -= 1.0
    return -c / 2.0 * (t * ( t -2.0) - 1) + b
  end

  # cubic ease in out
  # @param t [Number] 時間(0.0 - 1.0)
  # @param b [Number] 基準値
  # @param c [Number] 変化量
  # @param d [Number] 1.0
  # @return [Number] 結果

  def ease_in_out_cubic(t, b, c, d)
    t /= (d / 2.0)
    return (c / 2.0 * t * t * t + b) if t < 1.0
    t -= 2.0
    return c / 2.0 * (t * t * t + 2.0) + b
  end
end


if __FILE__ == $0 then

  include Easing

  t = 0
  v_begin = 0
  v_change = 360
  v_duration = 1.0

  x = 0

  img = Image.new(8, 8, C_WHITE)

  Window.caption = "Easing Test"

  Window.loop do
    break if Input.keyPush?(K_ESCAPE)

    if Input.keyDown?(K_SPACE)
      y = ease_in_out_quad(t, v_begin, v_change, v_duration)
    else
      y = ease_in_out_cubic(t, v_begin, v_change, v_duration)
    end

    Window.draw(x, y, img)

    x += 5
    t += 0.01
    if t > 1.2
      t = 0
      x = 0
    end
  end
end
