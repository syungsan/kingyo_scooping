#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE= "s"
require "jcode"

# input_dialog.rb Ver 0.8.0
# 画面解像度選択ダイアログ

# require "vr/vruby"
# require "vr/vrcontrol"
require "vr/vrhandler"
require "vr/vrdialog"


class ResolutionDialog < VRModalDialog

  if __FILE__ == $0
    require "../lib/display"
  else
    require "./lib/display"
  end

  DIALOG_WIDTH = 400
  DIALOG_HEIGHT = 500
  IS_DIALOG_CENTER = true
  DIALOG_FONT_NAME = "ＭＳ Ｐゴシック"

  include VRClosingSensitive
  include Display

  def construct

    initWindowRect = setDisplayFixWindow([DIALOG_WIDTH, DIALOG_HEIGHT], IS_DIALOG_CENTER)
    if initWindowRect[:windowX] and initWindowRect[:windowY] then
      windowX, windowY = initWindowRect[:windowX], initWindowRect[:windowY]
      dialog_x = windowX
      dialog_y = windowY
    end

    self.caption = "#{options[:app_name]} Ver#{options[:version]} <Select resolution>"
    self.move dialog_x, dialog_y, DIALOG_WIDTH, DIALOG_HEIGHT

    addControl(VRStatic, "title_label", "プレイする解像度を選んでください", 0, 0, 20 * "プレイする解像度を選んでください".length * 0.5, 20)
    addControl(VRStatic, "info_label", "表示可能な解像度の一覧", 0, 0, 16 * "表示可能な解像度の一覧".length * 0.5, 16)
    addControl(VRListbox,"item_listbox","list of resolutions",0,0,DIALOG_WIDTH * 0.8,DIALOG_HEIGHT * 0.4,0x00800000)

    addControl(VRRadiobutton,"full_radio_button","full screen",0,0,130,20,0x0300)
    addControl(VRRadiobutton,"windowed_radio_button","windowed",0,0,130,20,0x0300)

    addControl(VRButton, "ok_button", "OK", 0, 0, 120, 40)
    addControl(VRButton, "cancel_button", "キャンセル", 0, 0, 120, 40)

    @returns = Array.new(2)
  end

  def self_created

    @title_label.x = (DIALOG_WIDTH - @title_label.w) * 0.5
    @title_label.y = (DIALOG_HEIGHT - @title_label.h) * 0.05

    @info_label.x = (DIALOG_WIDTH - @info_label.w) * 0.5
    @info_label.y = (DIALOG_HEIGHT - @info_label.h) * 0.13

    @item_listbox.x = (DIALOG_WIDTH - @item_listbox.w) * 0.5
    @item_listbox.y = (DIALOG_HEIGHT - @item_listbox.h) * 0.3

    @full_radio_button.x = (DIALOG_WIDTH - @full_radio_button.w) * 0.5
    @full_radio_button.y = (DIALOG_HEIGHT - @full_radio_button.h) * 0.63

    @windowed_radio_button.x = (DIALOG_WIDTH - @windowed_radio_button.w) * 0.5
    @windowed_radio_button.y = (DIALOG_HEIGHT - @windowed_radio_button.h) * 0.7

    @ok_button.x = (DIALOG_WIDTH * 0.333) - (@ok_button.w * 0.5)
    @ok_button.y = (DIALOG_HEIGHT - @ok_button.h) * 0.87

    @cancel_button.x = (DIALOG_WIDTH * 0.667) - (@cancel_button.w * 0.5)
    @cancel_button.y = (DIALOG_HEIGHT - @cancel_button.h) * 0.87

    items = options[:resolutions].map { |resolution| "#{resolution[0]} × #{resolution[1]}" }
    @item_listbox.setListStrings items
    @item_listbox.select(0)
    @resolution_index = 0

    @full_radio_button.check true
    @window_mode = :full

    # フォントの設定
    font = @screen.factory.newfont(DIALOG_FONT_NAME, 20)
    @title_label.setFont font

    font = @screen.factory.newfont(DIALOG_FONT_NAME, 16)
    @info_label.setFont font

    font = @screen.factory.newfont(DIALOG_FONT_NAME, 20)
    @item_listbox.setFont font

    font = @screen.factory.newfont(DIALOG_FONT_NAME, 18)
    @full_radio_button.setFont font

    font = @screen.factory.newfont(DIALOG_FONT_NAME, 18)
    @windowed_radio_button.setFont font

    font = @screen.factory.newfont(DIALOG_FONT_NAME, 24)
    @ok_button.setFont font

    font = @screen.factory.newfont(DIALOG_FONT_NAME, 24)
    @cancel_button.setFont font
  end

  def item_listbox_selchanged
    @resolution_index = @item_listbox.selectedString
  end

  def full_radio_button_clicked
    @window_mode = :full
  end

  def windowed_radio_button_clicked
    @window_mode = :windowed
  end

  def ok_button_clicked
    @returns[0] = options[:resolutions][@resolution_index]
    if @window_mode == :full then
      @window_mode = false
    else
      @window_mode = true
    end
    @returns[1] = @window_mode
    close(@returns)
  end

  def cancel_button_clicked
    close("cancel")
  end

  def self_close
  end
end


if __FILE__ == $0

  require "dxruby"

  APPLICATION_NAME = "金魚すくい"
  VERSION_NUMBER = "0.9.4"

  resolutions =  Window.get_screen_modes.select { |resolution| resolution.delete_at(2) }.uniq!.sort {|a,b| a[0] <=> b[0]}.reverse

  option = {:resolutions=>resolutions, :app_name=>APPLICATION_NAME, :version=>VERSION_NUMBER}
  p resolution = VRLocalScreen.modalform(nil, nil, ResolutionDialog, nil, option)
end
