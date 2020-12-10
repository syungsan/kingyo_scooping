#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

# Templete Project main.rb Ver 1.2

# exerbで固めたexeから起動するときカレントディレクトリをexeのパスにするネ！
if defined?(ExerbRuntime)
  Dir.chdir(File.dirname(ExerbRuntime.filepath))
end

# この実行スクリプトのあるディレクトリに移動
Dir.chdir(File.expand_path("..", __FILE__))

# 各種ライブラリの場所一括設定
$LOAD_PATH.push("./lib", "./scripts", "./lib/dxruby", "./lib/audio")

# 使用しないライブラリはコメントアウト
require "dxruby" # DXRuby本体
require "display" # ディスプレイ情報取得
require "scene" # 画面遷移
require "fonts" # ラベル作成
require "button" # ボタン作成
require "color" # カラー情報（モジュールなので要include）
require "ui" # その他のユーザインタフェース
require "files" # ファイル操作（モジュールなので要include） log.rbを使うときも必要
# require "images" # 画像オブジェクト一般
# require "common" # Ruby汎用ライブラリ（モジュールなので要include）
# require "excel" # Excel操作用
# require "sqlite3" # データベース
# require "weighted_randomizer" # 重み付き乱択
# require "encode" # 文字コード変換
# require "json/pure" # JSON
# require "linear_algebra" # 線形代数
# require "win32/open3" # 外部コマンド実行

# Audio解析関連
# require "wav-file"
# require "mciver3"
# require "wav_analyze"

# mp3などを鳴らすため
=begin
Dir.chdir("./lib/dxruby") do
  require "Bass"
end
=end

require "border"
require "kingyo"
require "poi"

# システム・パラメータ #################################################################################################
# アプリケーション設定
APPLICATION_NAME = "私のアプリケーション"
COPYLIGHT = "Powered by Ruby & DXRuby."
VERSION_NUMBER = "0.8"
# APPLICATION_ICON =

FPS = 60
FRAME_STEP = 1
FRAME_SKIP = true
WINDOWED = true

# 初期のウィンドウカラー（color.rb参照）
include Color
DEFAULT_BACK_GROUND_COLER = C_WHITE

# 画面サイズのワイド時とスクエア時の選択肢（display.rb参照）
include Display
WINDOW_WIDE_SIZE = FHD
WINDOW_SQUARE_SIZE = XGA

# 起動時にウィンドウを画面中央に表示する
IS_WINDOW_CENTER = true

# ログを記録するかどうか
IS_LOG = false

if IS_LOG then
  require "log"

  # ログ収録フォルダの場所
  LOG_DIR = "./log"
end
########################################################################################################################
# 名前入力ダイアログ表示 ##################################################################################################
IS_NAME_INPUT = false

if IS_NAME_INPUT then
  require "input_dialog"
  mes = VRLocalScreen.modalform(nil, nil, InputDialog)

  exit if not mes or mes == "Cancel"
else
  $user_name = "noname"
end
########################################################################################################################
# ゲーム・パラメータ ###################################################################################################
# 音
CLICK_SE = "./sounds/push13.wav"

# 画像
STONE_TILE_IMAGE = "./images/stone_tile.png"
AQUARIUM_BACK_IMAGE = "./images/seamless-water.jpg"

# フォント
# FONT = ""

# フォントのインストール
# Font.install(FONT)
########################################################################################################################
########################################################################################################################
initWindowRect = setDisplay(WINDOW_WIDE_SIZE, WINDOW_SQUARE_SIZE, IS_WINDOW_CENTER)
if initWindowRect[:windowX] and initWindowRect[:windowY] then
  windowX, windowY = initWindowRect[:windowX], initWindowRect[:windowY]
  Window.x = windowX
  Window.y = windowY
end
$is_square = initWindowRect[:isSquare]

Window.width  = initWindowRect[:windowWidth]
Window.height = initWindowRect[:windowHeight]
Window.caption = "#{APPLICATION_NAME} Ver#{VERSION_NUMBER}"
# Window.loadIcon(APPLICATION_ICON)
Window.bgcolor = DEFAULT_BACK_GROUND_COLER
Window.frameskip = FRAME_SKIP
Window.windowed = WINDOWED
########################################################################################################################

FIRST_STAGE_NUMBER = 1

KINGYO_NUMBERS = [60]
KINGYO_SCALE_RANGES = [[0.5, 1]]
KINGYO_HOVER_RANGES = [[0, 1]]
KINGYO_SPEED_RANGES = [{"move"=>[1, 5], "escape"=>[1, 5]}]
KINGYO_MODE_RANGES = [{"wait"=>[0, 100], "move"=>[0, 100], "escape"=>[0, 100]}]


# タイトル・シーン
class TitleScene < Scene::Base

  @@clickSE = Sound.new(CLICK_SE)

  def init

    # 必要最小限のグローバル変数を初期化
    # $score, $userNameなど…

    # IS_LOGフラグはログを記録するすべての場所に付ける
    if IS_LOG then
      $log = Log.new # ログオブジェクト生成

      # 仮に伝統的なログファイルのパスを設定するとともにログフォルダの作成（引数で任意のフォルダとファイル名を指定）
      $log.setLog("#{LOG_DIR}/#{$log.startDate}", "#{APPLICATION_NAME}_#{$log.startDatetime}.csv")

      # $log.parent_dir = "#{LOG_DIR}/#{$log.startDate}/#{APPLICATION_NAME}_Ver#{VERSION_NUMBER}_#{$user_name}_#{$log.startDatetime}"
      # $log.setLog($log.parent_dir)
    end
    # ログファイルのpathの作成にログクラスのメンバ変数startDate, startDateTime, parent_dirが参照できる

    @titleLabel = Fonts.new(0, 0, APPLICATION_NAME, Window.height * 0.1, C_BLACK)
    @versionNumberLabel = Fonts.new(0, 0, "Version #{VERSION_NUMBER}", @titleLabel.get_height * 0.3, C_BLACK)
    @copyLightLabel = Fonts.new(0, 0, COPYLIGHT, Window.height * 0.05, C_BLACK)

    startButtonText = "スタート"
    startButtonHeight = Window.height * 0.05
    @startButton = Button.new(0, 0, startButtonHeight * startButtonText.size * 0.5, startButtonHeight, startButtonText, startButtonHeight)

    exitButtonText = "Exit"
    exitButtonHeight = Window.height * 0.03
    @exitButton = Button.new(0, 0, exitButtonHeight * exitButtonText.size * 0.5, exitButtonHeight, exitButtonText, exitButtonHeight)

    windowModeButtonText = "Full/Window"
    windowModeButtonHeight = Window.height * 0.03
    @windowModeButton = Button.new(0, 0, windowModeButtonHeight * windowModeButtonText.size * 0.5, windowModeButtonHeight, windowModeButtonText, windowModeButtonHeight)

    changeWindowSizeTexts = ["ワイド画面", "スクウェア画面"]
    @changeWindowSizeLabels = []
    @radioButtons = []

    2.times do |index|
      changeWindowSizeLabel = Fonts.new(0, 0, changeWindowSizeTexts[index], Window.height * 0.03, C_BLACK)
      @changeWindowSizeLabels << changeWindowSizeLabel
      radioButton = RadioButton.new(0, 0, index)
      @radioButtons << radioButton
    end
    @radioButtons[$is_square].setCheck(true)

    # Write your code...

    self.setPosition
  end

  def setPosition

    @titleLabel.set_pos((Window.width - @titleLabel.get_width) * 0.5, (Window.height - @titleLabel.get_height) * 0.2)
    @versionNumberLabel.set_pos(@titleLabel.x + @titleLabel.get_width - @versionNumberLabel.get_width, @titleLabel.y + @titleLabel.get_height)
    @copyLightLabel.set_pos((Window.width - @copyLightLabel.get_width) * 0.5, (Window.height - @copyLightLabel.get_height) * 0.9)
    @startButton.set_pos((Window.width - @startButton.w) * 0.5, (Window.height - @startButton.h) * 0.7)
    @exitButton.set_pos(Window.width - @exitButton.w, 0)
    @windowModeButton.set_pos(Window.width - (@exitButton.w + @windowModeButton.w), 0)

    2.times do |index|
      @changeWindowSizeLabels[index].set_pos(Window.width * 0.03, Window.height * 0.9 + (Window.height * 0.05 * index))
      @radioButtons[index].setPos(Window.width * 0.01, Window.height * 0.9 + (Window.height * 0.05 * index))
    end

    # Write your code...
  end

  def update

    if @startButton.pushed?
      @@clickSE.play
      self.next_scene = GameScene
    end

    if @windowModeButton.pushed? then
      if Window.windowed? then
        Window.windowed = false
      else
        Window.windowed = true
      end
      @@clickSE.play
    end

    if @exitButton.pushed? or Input.key_push?(K_ESCAPE) then
      exit
    end

    # ラジオボタンの排他処理 ##########
    checkID = nil
    for radioButton in @radioButtons do
      if radioButton.checked? then
        @@clickSE.play
        checkID = radioButton.id

        case checkID
        when 0 then
          Window.resize(WINDOW_WIDE_SIZE[0], WINDOW_WIDE_SIZE[1])
          $is_square = 0
          self.setPosition
        when 1 then
          Window.resize(WINDOW_SQUARE_SIZE[0], WINDOW_SQUARE_SIZE[1])
          $is_square = 1
          self.setPosition
        end
      end
    end

    if checkID then
      for radioButton in @radioButtons do
        unless radioButton.id == checkID then
          radioButton.setCheck(false)
        end
      end
    end
    ###################################

    # Write your code...
  end

  def render
    @titleLabel.render
    @versionNumberLabel.render
    @copyLightLabel.render
    @startButton.render
    @exitButton.render
    @windowModeButton.render

    2.times do |index|
      @radioButtons[index].draw
      @changeWindowSizeLabels[index].render
    end

    # Write your code...
  end
end


# ゲーム・シーン
class GameScene < Scene::Base

  include Common

  @@clickSE = Sound.new(CLICK_SE)

  @@stone_tile_image = Image.load(STONE_TILE_IMAGE)
  @@aquarium_back_image = Image.load(AQUARIUM_BACK_IMAGE)

  line_width = 50
  border_top = Border.new(0, -1 * line_width, Window.width, line_width, 0)
  border_left = Border.new(-1 * line_width, 0, line_width, Window.height, 1)
  border_right = Border.new(Window.width, 0, line_width, Window.height, 2)
  border_bottom = Border.new(0, Window.height, Window.width, line_width, 3)
  @@borders = [border_top, border_left, border_right, border_bottom]

  def init

    exitButtonText = "Exit"
    exitButtonHeight = Window.height * 0.03
    @exitButton = Button.new(0, 0, exitButtonHeight * exitButtonText.size * 0.5, exitButtonHeight, exitButtonText, exitButtonHeight)
    @exitButton.set_pos(Window.width - @exitButton.w, 0)

    windowModeButtonText = "Full/Window"
    windowModeButtonHeight = Window.height * 0.03
    @windowModeButton = Button.new(0, 0, windowModeButtonHeight * windowModeButtonText.size * 0.5, windowModeButtonHeight, windowModeButtonText, windowModeButtonHeight)
    @windowModeButton.set_pos(Window.width - (@exitButton.w + @windowModeButton.w), 0)

    @poi = Poi.new(0, 0, 0.8)
    @poi.x = (Window.width - @poi.width) * 0.5
    @poi.y = (Window.height - @poi.height) * 0.5

    # キャラクタ・スプライトのマウスイベントを処理する場合はコメント外す
    # いまマウスで掴んでるオブジェクト
    @item = nil

    # キャラクタをオブジェクト配列に追加
    @charas = [@poi]

    # マウスカーソルの衝突判定用スプライト
    @mouse = Sprite.new
    @mouse.collision = [0, 0]

    # ログの書き込みと読み込みのテスト
    if IS_LOG then
      data = [1, 2, 3, 4]
      $log.write(data)
      $log.setLog("#{LOG_DIR}/#{$log.startDate}/sub", "test.csv")
      $log.write(data)
      $log.screenShot
      $log.add(data)
      p $log.read
    end

    # Write your code...
    stone_tile_image_scale = 0.5
    stone_tile_rt = RenderTarget.new(@@stone_tile_image.width * stone_tile_image_scale, @@stone_tile_image.height * stone_tile_image_scale)
    stone_tile_rt.draw_scale(@@stone_tile_image.width * (stone_tile_image_scale - 1.0) * 0.5, @@stone_tile_image.height * (stone_tile_image_scale - 1.0) * 0.5, @@stone_tile_image, stone_tile_image_scale, stone_tile_image_scale)
    @stone_tile_image = stone_tile_rt.to_image
    @@stone_tile_image.dispose
    stone_tile_rt.dispose

    aquarium_back_rt = RenderTarget.new(Window.width, Window.height)
    aquarium_back_rt.drawTile(0, 0, [[0]], [@@aquarium_back_image], nil, nil, nil, nil)
    @aquarium_back_image = aquarium_back_rt.to_image
    @@aquarium_back_image.dispose
    aquarium_back_rt.dispose

    @stage_number = FIRST_STAGE_NUMBER - 1
    self.stage_init(@stage_number)
  end

  def stage_init(stage_no)

    @kingyos = []
    KINGYO_NUMBERS[@stage_number].times do |index|
      kingyo = Kingyo.new(0, 0, KIND_OF_KINGYOS[rand(2)], rand(360), rand_float(KINGYO_SCALE_RANGES[@stage_number][0], KINGYO_SCALE_RANGES[@stage_number][1]), index, KINGYO_HOVER_RANGES[@stage_number], KINGYO_SPEED_RANGES[@stage_number], KINGYO_MODE_RANGES[@stage_number])
      kingyo.x = random_int(@@borders[1].x + @@borders[1].width, @@borders[2].x - kingyo.width)
      kingyo.y = random_int(@@borders[0].y + @@borders[0].height, @@borders[3].y - kingyo.height)
      @kingyos.push(kingyo)
    end
  end

  def update

    if @windowModeButton.pushed? then
      if Window.windowed? then
        Window.windowed = false
      else
        Window.windowed = true
      end
      @@clickSE.play
    end

    if @exitButton.pushed? or Input.key_push?(K_ESCAPE) then
      exit
    end

    # キャラクタ・スプライトのマウスイベントを処理する場合はコメント外す
    self.mouseProcess

    Sprite.update(@charas)
    Sprite.check(@charas)

    Sprite.check(@item, @charas) if @item

    # Write your code...
    if not @kingyos.empty? then
      @kingyos.each do |kingyo|
        kingyo.update
      end
    end
    Sprite.check(@@borders + @kingyos)
  end

  def render

    # Write your code...
    Window.drawTile(0, 0, [[0]], [@stone_tile_image], nil, nil, nil, nil)
    Window.draw_ex(0, 0, @aquarium_back_image, :alpha=>180)

    @@borders.each do |border|
      border.draw
    end

    # キャラクタ・スプライトのマウスイベントを処理する場合はコメント外す
    if not @charas.empty? then
      @charas.reverse.each do |obj|
        obj.draw if not obj.nil?
      end
    end
    Sprite.draw(@item) if @item

    if not @kingyos.empty? then
      @kingyos.each do |kingyo|
        kingyo.draw
      end
    end

    @exitButton.render
    @windowModeButton.render
  end

  # キャラクタ・スプライトのマウスイベントを処理する場合はコメント外す
  def mouseProcess

    oldX, oldY = @mouse.x, @mouse.y
    @mouse.x, @mouse.y = Input.mouse_pos_x, Input.mouse_pos_y

    # ボタンを押したら判定
    if Input.mouse_push?(M_LBUTTON)
      @charas.each_with_index do |obj, i|
        if @mouse === obj

          # Write your code. when mouse push. #####

          # オブジェクトをクリックできたら並べ替えとitem設定
          @charas.delete_at(i)
          @item = obj
          break
        end
      end
    end

    # ボタンを押している間の処理
    if Input.mouse_down?(M_LBUTTON)
      if @item then

        # Write your code. when mouse down. #####

        if @item.is_drag then
          @item.x += @mouse.x - oldX
          @item.y += @mouse.y - oldY
        end
      end
    else
      if @item then
        if @mouse === @item then

          # Write your code. when mouse release. #####

        end
        # ボタンが離されたらオブジェクトを解放
        @charas.unshift(@item)
        @item = nil
      end
    end
  end
end

Scene.main_loop TitleScene, FPS, FRAME_STEP

=begin
# win32_open3 example
# Try each command as you like...
cmd = "dir /w"

Open3.popen3(cmd) do |io_in, io_out, io_err|
  error = io_err.read
  if error && error.length > 0
    puts 'Error: ' + error
    break
  else
    # puts io_in.write("hoge")
    output = io_out.read
    puts 'Output: ' + output if output
  end
end
=end
