#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

require "dxruby"


class SpriteFont < Sprite

  attr_accessor :id, :name, :is_drag
  attr_reader :width, :height, :mode

  if __FILE__ == $0 then
    require "../lib/dxruby/easing"
  else
    require "./lib/dxruby/easing"
  end
  include Easing

  def initialize(x=0, y=0, text="sample", font_size=24, font_color=[255, 255, 255], frame_color=[0, 0, 0, 0], option={},
                 id=0, name="sprite_font", is_drag=false, target=Window)
    option = {:font_name=>"ＭＳ Ｐゴシック", :weight=>400, :italic=>false, :auto_fitting=>false, :edge=>false,
              :edge_color=>[0, 0, 0], :edge_width=>2, :edge_level=>4, :shadow=>false, :shadow_edge=>false,
              :shadow_color=>[0, 0, 0], :shadow_x=>1, :shadow_y=>1, :anti_alias=>true}.merge(option)
    super()

    self.x = x
    self.y = y
    font = Font.new(font_size, option[:font_name], {:weight=>option[:weight], :italic=>option[:italic],
                                                    :auto_fitting=>option[:auto_fitting]})
    image = Image.new(font.get_width(text), font_size, frame_color) unless option[:shadow]
    image =
      Image.new(font.get_width(text) + option[:shadow_x], font_size + option[:shadow_y], frame_color) if option[:shadow]
    image.draw_font_ex(0, 0, text, font, {:color=>font_color, :edge=>option[:edge], :edge_color=>option[:edge_color],
                                          :edge_width=>option[:edge_width], :edge_level=>option[:edge_level],
                                          :shadow=>option[:shadow], :shadow_edge=>option[:shadow_edge],
                                          :shadow_color=>option[:shadow_color], :shadow_x=>option[:shadow_x],
                                          :shadow_y=>option[:shadow_y], :anti_alias=>option[:anti_alias]})
    self.image = image
    @width = self.image.width
    @height = self.image.height
    @name = name
    @id = id
    @is_drag = is_drag
    self.target = target
    @mode = :wait
  end

  def set_pos(x, y)
    self.x = x
    self.y = y
  end

  def fade_move(v_begins=[0, 0], v_changes=[100, 100], weight_ratio=2.0, bound_rect=[0, 0, 800, 600],
                in_duration=0.5, stop_duration=0.5, out_duration=0.5)
    @in_time = 0
    @v_begins = v_begins
    @v_changes = v_changes
    @in_duration = in_duration
    @stop_duration = stop_duration
    @out_duration = out_duration
    @weight_ratio = weight_ratio
    @bound_rect = bound_rect
    @stop_time = 0
    @out_time = 0
    @switch = :in
    @mode = :fade_move
  end

  def update

    if @mode == :fade_move then
      if @switch == :in then
        if @in_time <= @in_duration then
          self.x = ease_in_out_quad(@in_time, @v_begins[0], @v_changes[0], @in_duration)
          self.y = ease_in_out_quad(@in_time, @v_begins[1], @v_changes[1], @in_duration)
          self.scale_x = ease_in_out_quad(@in_time, 0, @weight_ratio, @in_duration)
          self.scale_y = ease_in_out_quad(@in_time, 0, @weight_ratio, @in_duration)
          self.alpha = ease_in_out_quad(@in_time, 0, 255, @in_duration)
          @in_time += 0.01
        else
          @in_time = 0
          @switch = :stop
        end
      end
      if @switch == :stop then
        if @stop_time <= @stop_duration then
          @stop_time += 0.01
        else
          @stop_time = 0
          @switch = :out
        end
      end
      if @switch == :out then
        if @out_time <= @out_duration then
          self.alpha = 255 * (1 - (1 / @out_duration * @out_time))
          @out_time += 0.01
        else
          @out_time = 0
          @mode = :wait
          self.vanish
        end
      end
      self.x = @bound_rect[0] if self.x < @bound_rect[0]
      self.x = @bound_rect[0] + @bound_rect[2] - self.width if self.x > @bound_rect[0] + @bound_rect[2] - self.width
      self.y = @bound_rect[1] if self.y < @bound_rect[1]
      self.y = @bound_rect[1] + @bound_rect[3] - self.height if self.y > @bound_rect[1] + @bound_rect[3] - self.height
    end
  end

  def draw
    self.target.draw_ex(self.x, self.y, self.image, {:scale_x=>self.scale_x, :scale_y=>self.scale_y, :center_x=>nil,
                                                     :center_y=>nil, :alpha=>self.alpha, :blend=>:alpha,
                                                     :color=>[255, 255, 255], :angle=>self.angle, :z=>self.z})
  end
end


if __FILE__ == $0 then

  Window.width = 800
  Window.height = 600

  sprite_font = SpriteFont.new(0, 0, "これはテストです。", 18, C_RED, C_DEFAULT,
                               {:shadow=>true, :shadow_color=>[128, 128, 128, 128]})
  sprite_font.fade_move

  Window.bgcolor = C_GREEN
  Window.loop do
    if sprite_font then
      sprite_font.draw if sprite_font
      sprite_font.update if sprite_font
    end
    sprite_font = nil if sprite_font and sprite_font.vanished?
  end
end
