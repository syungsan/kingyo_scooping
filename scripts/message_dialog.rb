#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

require "dxruby"


class MessageDialog

  attr_accessor :shadow_x, :shadow_y, :name, :id, :target, :z, :ok_button, :cancel_button
  attr_reader :width, :height

  if __FILE__ == $0 then
    require "../lib/dxruby/fonts"
    require "../lib/dxruby/roundbox"
    require "../lib/dxruby/button"
  else
    require "./lib/dxruby/fonts"
    require "./lib/dxruby/roundbox"
    require "./lib/dxruby/button"
  end

  SHADOW_OFFSET_X = 5
  SHADOW_OFFSET_Y = 5

  def initialize(x=0, y=0, width=300, height=100, type=1, option={})
    option = {:frame_thickness=>2, :radius=>10, :bg_color=>C_WHITE, :frame_color=>C_GREEN,
              :name=>"message_window", :id=>0, :target=>Window, :z=>0}.merge(option)

    @frame_thickness = option[:frame_thickness]
    @radius = option[:radius]
    @bg_color = option[:bg_color]
    @frame_color = option[:frame_color]

    @x = x
    @y = y
    @width = width
    @height = height

    @target = option[:target]
    @id = option[:id]
    @name = option[:name]
    @z = option[:z]

    @shadow_x = SHADOW_OFFSET_X
    @shadow_y = SHADOW_OFFSET_Y

    @image = Image.new(@width, @height)
    @messages = [Fonts.new(), Fonts.new()]

    @type = type

    button_width = @width * 0.3
    button_height = button_width * 0.4

    if @type == 0 then
      @ok_button = Button.new(@x + (@width - button_width) * 0.5, (@y + @height - button_height) * 0.8,
                              button_width, button_height, string="OK",
                              font_size=button_height * 0.8)
    elsif @type == 1 then
      @ok_button = Button.new(@x + (@width - button_width) * 0.2, (@y + @height - button_height) * 0.8,
                              button_width, button_height, string="OK",
                              font_size=button_height * 0.8)
      @cancel_button = Button.new(@x + (@width - button_width) * 0.8, (@y + @height - button_height) * 0.8,
                              button_width, button_height, string="Cancel",
                              font_size=button_height * 0.8)
    end


    self.constract
  end

  def set_pos(x, y)
    @x = x
    @y = y

    if @type == 0 then
      @ok_button.set_pos(@x + (@width - @ok_button.width) * 0.5, @y + (@height - @ok_button.height) * 0.8)
    elsif @type == 1 then
      @ok_button.set_pos(@x + (@width - @ok_button.width) * 0.2, @y + (@height - @ok_button.height) * 0.8)
      @cancel_button.set_pos(@x + (@width - @ok_button.width) * 0.8, @y + (@height - @ok_button.height) * 0.8)
    end
  end

  def constract

    @image.clear
    @image.roundbox_fill(0, 0, @width, @height, @radius, @bg_color)

    @frame_thickness.times do |index|
      @image.roundbox(index, index, @width - 1 - index, @height - 1 - index, @radius, @frame_color)
    end
    @shadow = @image.flush([64, 0, 0, 0])
  end

  def set_message(string="", sub_string="", font_size=24, font_color=C_BLACK,
                  font_name="ＭＳ Ｐゴシック", italic=false, weight=false)

    self.constract

    strings = [string, sub_string]
    font_sizes = [font_size, font_size * 0.5]

    @messages.each_with_index do |message, index|
      unless strings[index] == "" then
        message.target = @image
        message.string = strings[index]
        message.size = font_sizes[index]
        message.color = font_color
        message.font_name = font_name
        message.set_italic = italic
        message.set_weight = weight
        message.width
        message.set_pos((@width - message.width) * 0.5, (@height - message.height) * 0.2 + (message.height * 2 * index))
        message.draw
      end
    end
  end

  def draw
    @target.draw(@x + @shadow_x, @y + @shadow_y, @shadow, @z)
    @target.draw(@x, @y, @image, @z)

    @ok_button.draw
    @cancel_button.draw if @type == 1
  end

  def vanish
    @message.vanish
    @shadow.dispose
    @image.dispose
  end
end


if __FILE__ == $0 then

  require "../lib/dxruby/images"

  Window.width = 1280
  Window.height = 720

  MIKACHAN_FONT = "../fonts/mikachanALL.ttc"
  Font.install(MIKACHAN_FONT)

  OK_BUTTON_IMAGE = "../images/m_4.png"
  CANCEL_BUTTON_IMAGE = "../images/m_1.png"

=begin
  message_dialog_width = Window.width * 0.5
  message_dialog_height = message_dialog_width * 0.5
  message_dialog_option = {:frame_thickness=>(message_dialog_width * 0.02).round, :radius=>message_dialog_height * 0.03,
                           :bg_color=>[128, 255, 255, 255], :frame_color=>C_YELLOW}
  message_dialog = MessageDialog.new(0, 0, message_dialog_width, message_dialog_height,
                                     1, message_dialog_option)
  message_dialog.set_message("通信エラー…", "タイトルに戻ります。",
                             message_dialog.height * 0.25, C_RED, "みかちゃん")
=end
  message_dialog_width = Window.width * 0.5
  message_dialog_height = message_dialog_width * 0.5
  message_dialog_option = {:frame_thickness=>(message_dialog_height * 0.02).round, :radius=>message_dialog_height * 0.03,
                           :bg_color=>[128, 255, 255, 255], :frame_color=>C_CYAN}
  message_dialog = MessageDialog.new(0, 0, message_dialog_width, message_dialog_height,
                                     1, message_dialog_option)
  message_dialog.set_message("タイトルに戻りますか？", "",
                             message_dialog.height * 0.15, C_RED, "みかちゃん")

  message_dialog.set_pos((Window.width - message_dialog.width) * 0.5, (Window.height - message_dialog.height) * 0.5)

  ok_button_image = Image.load(OK_BUTTON_IMAGE)
  message_dialog.ok_button.set_image(Images.fit_resize(
    ok_button_image, message_dialog.ok_button.width, message_dialog.ok_button.height))

  cancel_button_image = Image.load(CANCEL_BUTTON_IMAGE)
  message_dialog.cancel_button.set_image(Images.fit_resize(
    cancel_button_image, message_dialog.cancel_button.width, message_dialog.cancel_button.height))

  Window.bgcolor = C_BLUE
  Window.loop do
    if message_dialog and message_dialog.ok_button.pushed? then
      p "ok_button pushed"
    end
    if message_dialog and message_dialog.cancel_button.pushed? then
      p "cancel_button pushed"
    end
    message_dialog.ok_button.hovered?
    message_dialog.cancel_button.hovered?
    message_dialog.draw if message_dialog
  end
end
