#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE= "s"
require "jcode"

# Display.rb Ver 1.0
# ディスプレイ情報取得用モジュール

require "Win32API"


module Display

# ディスプレイ解像度のリスト
  SVGA = [800, 600]
  XGA = [1024, 768]
  HD = [1280, 720]
  WXGA = [1280, 768]
  FWXGA = [1366, 768]
  WXGAPP = [1600, 900]
  FHD = [1920, 1080]
  WUXGA = [1920, 1200]

  def setDisplay(wideSize=HD, squareSize=XGA, isCenter=true)

    # ディスプレイの解像度取得
    smCxScreen = 0
    smCyScreen = 1

    displayDimension = Win32API.new('user32', 'GetSystemMetrics', %w(i), 'i') # Win32APIを叩いてます
    displayWidth = displayDimension.call(smCxScreen)
    displayHeight = displayDimension.call(smCyScreen)

    # 初期ウィンドウサイズの設定
    if (displayWidth / displayHeight.to_f).round <= (4 / 3.to_f).round then
      initWindowSize = squareSize # スタンダード・スクウェアサイズの場合
      _isSquare = 1
    else
      initWindowSize = wideSize # その他はとりあえずみんなワイドとみなす
      _isSquare = 0
    end

    # ウィンドウを画面真ん中に表示するため
    if isCenter then
      _windowX = (displayWidth - initWindowSize[0]) * 0.5
      _windowY = (displayHeight - initWindowSize[1]) * 0.5
    else
      _windowX = nil
      _windowY = nil
    end

    return {:isSquare=>_isSquare, :windowX => _windowX, :windowY => _windowY, :windowWidth => initWindowSize[0], :windowHeight => initWindowSize[1]}
  end

  def setDisplayFixWindow(windowSize=HD, isCenter=true)

    # ディスプレイの解像度取得
    smCxScreen = 0
    smCyScreen = 1

    displayDimension = Win32API.new('user32', 'GetSystemMetrics', %w(i), 'i') # Win32APIを叩いてます
    displayWidth = displayDimension.call(smCxScreen)
    displayHeight = displayDimension.call(smCyScreen)

    # ウィンドウを画面真ん中に表示するため
    if isCenter then
      _windowX = (displayWidth - windowSize[0]) * 0.5
      _windowY = (displayHeight - windowSize[1]) * 0.5
    else
      _windowX = nil
      _windowY = nil
    end

    return {:windowX => _windowX, :windowY => _windowY, :windowWidth => windowSize[0], :windowHeight => windowSize[1]}
  end

  def set_window_top(hWnd)

    set_window_pos = Win32API.new('User32', 'SetWindowPos', 'IIIIIII', 'I')

    hwnd_topmost = -1
    swp_nosize = 0x0001
    swp_nomove = 0x0002

    set_window_pos.call(hWnd, hwnd_topmost, 0, 0, 0, 0, swp_nosize | swp_nomove)
  end
end


if __FILE__ == $0

  include Display
  p getInitWindowRect(XGA)
end


