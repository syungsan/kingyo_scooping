#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE= "s"
require "jcode"

# input_dialog.rb Ver 1.0
# ログ情報入力用ダイアログ

require "vr/vruby"
require "vr/vrcontrol"
require "vr/vrhandler"
require "vr/vrdialog"


#キー入力を捕らえるEditクラス
class VRHookedEdit < VREdit

  include VRKeyFeasible

  def vrinit
    super
    #add_parentcall("char")
    addHandler WMsg::WM_KEYUP, "keyup", MSGTYPE::ARGINTINT, nil
    acceptEvents [WMsg::WM_KEYUP]
    add_parentcall("keyup")
  end
end


class InputDialog < VRModalDialog

  if __FILE__ == $0
    require "../lib/display"
    require "../lib/common"
  else
    require "./lib/display"
    require "./lib/common"
  end

  APPLICATION_NAME = "Test"
  VERSION_NUMBER = "0.0.0"
  DEFAULT_USER_NAME = "初音ミク"

  INPUT_DIALOG_WIDTH = 400
  INPUT_DIALOG_HEIGHT = 200
  IS_DIALOG_CENTER = true
  DIALOG_FONT_NAME = "ＭＳ Ｐゴシック"

  include VRClosingSensitive
  include VRDrawable
  include Display
  include Common

  def construct

    initWindowRect = setDisplayFixWindow([INPUT_DIALOG_WIDTH, INPUT_DIALOG_HEIGHT], IS_DIALOG_CENTER)
    if initWindowRect[:windowX] and initWindowRect[:windowY] then
      windowX, windowY = initWindowRect[:windowX], initWindowRect[:windowY]
      dialog_x = windowX
      dialog_y = windowY
    end

    self.caption = "#{APPLICATION_NAME} Ver#{VERSION_NUMBER} <Input User's Name>"
    self.move dialog_x, dialog_y, INPUT_DIALOG_WIDTH, INPUT_DIALOG_HEIGHT

    addControl(VRStatic, "title_label", "名前の入力", 0, 0, 28 * "名前の入力".length * 0.5, 28)
    addControl(VRHookedEdit, "name_edit", "", 0, 0, 300, 40)
    addControl(VRButton, "ok_button", "OK", 0, 200, 120, 40)
    addControl(VRButton, "cancel_button", "キャンセル", 200, 200, 120, 40)
  end

  def self_created

    @user_name = DEFAULT_USER_NAME

    @name_edit.text = @user_name

    @title_label.x = (INPUT_DIALOG_WIDTH - @title_label.w) * 0.5
    @title_label.y = (INPUT_DIALOG_HEIGHT - @title_label.h) * 0.1

    @name_edit.x = (INPUT_DIALOG_WIDTH - @name_edit.w) * 0.5
    @name_edit.y = (INPUT_DIALOG_HEIGHT - @name_edit.h) * 0.35

    @ok_button.x = (INPUT_DIALOG_WIDTH * 0.333) - (@ok_button.w * 0.5)
    @ok_button.y = (INPUT_DIALOG_HEIGHT - @ok_button.h) * 0.7

    @cancel_button.x = (INPUT_DIALOG_WIDTH * 0.667) - (@cancel_button.w * 0.5)
    @cancel_button.y = (INPUT_DIALOG_HEIGHT - @cancel_button.h) * 0.7

    # フォントの設定
    font = @screen.factory.newfont(DIALOG_FONT_NAME, 28)
    @title_label.setFont font

    font = @screen.factory.newfont(DIALOG_FONT_NAME, 32)
    @name_edit.setFont font

    font = @screen.factory.newfont(DIALOG_FONT_NAME, 24)
    font_changes = [@ok_button, @cancel_button]
    font_changes.each do |font_change|
      font_change.setFont font
    end
  end

  def name_edit_keyup(p, k)
    @user_name = @name_edit.text
  end

  def ok_button_clicked

    @user_name = "noname" if @name_edit.text == ""

    if check_input_box(@user_name)
      close(@user_name)
    else
      play_beep
      messageBox('入力する文字に  \\  /  :  *  ?  "  <  >  |   は使用できません   ', '入力エラー')
    end
  end

  def cancel_button_clicked
    close("Cancel")
  end

  def self_close
    p "Quit"
  end
end


# for Test
if __FILE__ == $0
  mes = VRLocalScreen.modalform(nil, nil, InputDialog)
  p mes # => ユーザネームの取得
end
