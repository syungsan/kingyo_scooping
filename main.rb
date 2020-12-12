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
require "container"
require "weed"
require "boss"

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

Z_POSITION_TOP = 300
Z_POSITION_UP = 200
Z_POSITION_DOWN = 100
Z_POSITION_BOTTOM = 0

KINGYO_NUMBERS = [60]
KINGYO_SCALE_RANGES = [[0.5, 1]]
KINGYO_SPEED_RANGES = [{:wait=>[0, 1], :move=>[1, 5], :escape=>[1, 5]}]
KINGYO_MODE_RANGES = [{:wait=>[0, 100], :move=>[0, 100], :escape=>[0, 100]}]

BOSS_NUMBERS = 4
BOSS_SCALE_RANGES = [0.5, 1]
BOSS_SPEED_RANGES = {:wait=>[0, 1], :move=>[1, 3], :against=>[1, 3]}
BOSS_MODE_RANGES = {:wait=>[0, 200], :move=>[0, 100], :against=>[0, 200]}

WEED_NUMBERS = [10]
WEED_SCALE_RANGES = [[0.4, 0.8]]

POINT_COUNT_IN_WINDOW = 60
POI_CATCH_ADJUST_RANGE_RATIO = 0.9

CONTAINER_CONTACT_ADJUST_RANGE_RATIO = 1.2
CONTAINER_RESERVE_ADJUST_RANGE_RATIO = 0.55

BASE_SCORES = {"red_kingyo"=>100, "black_kingyo"=>50, "weed"=>-100, "boss"=>10000}


# タイトル・シーン
class TitleScene < Scene::Base

  @@clickSE = Sound.new(CLICK_SE)

  def init

    # 必要最小限のグローバル変数を初期化
    # $score, $userNameなど…
=begin
    # IS_LOGフラグはログを記録するすべての場所に付ける
    if IS_LOG then
      $log = Log.new # ログオブジェクト生成

      # 仮に伝統的なログファイルのパスを設定するとともにログフォルダの作成（引数で任意のフォルダとファイル名を指定）
      $log.setLog("#{LOG_DIR}/#{$log.startDate}", "#{APPLICATION_NAME}_#{$log.startDatetime}.csv")

      # $log.parent_dir = "#{LOG_DIR}/#{$log.startDate}/#{APPLICATION_NAME}_Ver#{VERSION_NUMBER}_#{$user_name}_#{$log.startDatetime}"
      # $log.setLog($log.parent_dir)
    end
    # ログファイルのpathの作成にログクラスのメンバ変数startDate, startDateTime, parent_dirが参照できる
=end

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


class Mouse < Sprite
  attr_reader :name

  def initialize
    super()
    self.collision = [0, 0]
    @name = "mouse"
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

=begin
    # キャラクタ・スプライトのマウスイベントを処理する場合はコメント外す
    # いまマウスで掴んでるオブジェクト
    @item = nil

    # キャラクタをオブジェクト配列に追加
    @charas = [@poi]

    # マウスカーソルの衝突判定用スプライト
    @mouse = Sprite.new
    @mouse.collision = [0, 0]
=end
    @mouse = Mouse.new

=begin
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
=end

    # Write your code...
    @score = 0
    @score_label = Fonts.new(0, 0, "SCORE : #{@score}点", Window.height * 0.05, C_GREEN)

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

    @container = Container.new(0, 0, 0.8)
    @container.x = 300 # @@borders[2].x - @container.width
    @container.y = 300 # @@borders[3].y - @container.height
    @container.z = Z_POSITION_DOWN

    @poi = Poi.new(0, 0, 0.8, @mouse, @container, self)
    @poi.x = (Window.width - @poi.width) * 0.5
    @poi.y = (Window.height - @poi.height) * 0.5
    @poi.z = Z_POSITION_TOP

    @stage_number = FIRST_STAGE_NUMBER - 1
    self.stage_init

    @windows = []
  end

  def stage_init

    weeds = []
    WEED_NUMBERS[@stage_number].times do |index|
      weed = Weed.new(0, 0, rand(360), rand_float(WEED_SCALE_RANGES[@stage_number][0], WEED_SCALE_RANGES[@stage_number][1]), index)
      weed.x = random_int(@@borders[1].x + @@borders[1].width, @@borders[2].x - weed.width)
      weed.y = random_int(@@borders[0].y + @@borders[0].height, @@borders[3].y - weed.height)
      weed.z = Z_POSITION_TOP
      weeds.push(weed)
    end

    kingyos = []
    KINGYO_NUMBERS[@stage_number].times do |index|
      kingyo = Kingyo.new(0, 0, KIND_OF_KINGYOS[rand(2)], rand(360), rand_float(KINGYO_SCALE_RANGES[@stage_number][0], KINGYO_SCALE_RANGES[@stage_number][1]), index, KINGYO_SPEED_RANGES[@stage_number], KINGYO_MODE_RANGES[@stage_number])
      kingyo.x = random_int(@@borders[1].x + @@borders[1].width, @@borders[2].x - kingyo.width)
      kingyo.y = random_int(@@borders[0].y + @@borders[0].height, @@borders[3].y - kingyo.height)
      kingyo.z = Z_POSITION_TOP
      kingyos.push(kingyo)
    end

    bosss = []
    BOSS_NUMBERS.times do |index|
      boss = Boss.new(0, 0, rand(360), rand_float(BOSS_SCALE_RANGES[0], BOSS_SCALE_RANGES[1]), index, BOSS_SPEED_RANGES, BOSS_MODE_RANGES)
      boss.x = random_int(@@borders[1].x + @@borders[1].width, @@borders[2].x - boss.width)
      boss.y = random_int(@@borders[0].y + @@borders[0].height, @@borders[3].y - boss.height)
      boss.z = Z_POSITION_TOP
      bosss.push(boss)
    end

    @swimers = weeds + kingyos
    fisher_yates(@swimers)
    @swimers += bosss
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

    if @poi.mode != :try_gaze and @poi.mode != :transport then
      if (@windows.size <= POINT_COUNT_IN_WINDOW) then
        @windows.push([@mouse.x, @mouse.y])
      else
        @windows.shift(1)
      end

      if @windows.size >= POINT_COUNT_IN_WINDOW then
        if @poi.search_gaze_point(@windows) then
          @windows.clear
          @poi.mode = :try_gaze
          @poi.is_drag = false
        end
      end
    end

    if @poi.mode == :try_catch then
      catch_objects = []
      @swimers.each do |swimer|
        unless swimer.z == Z_POSITION_BOTTOM then
          if (swimer.x + swimer.center_x - (@poi.x + @poi.center_x)) ** 2 + ((swimer.y + swimer.center_y - (@poi.y + @poi.center_y)) ** 2) <= (@poi.width * 0.5 * POI_CATCH_ADJUST_RANGE_RATIO) ** 2 then
            swimer.mode = :catched
            catch_objects.push([swimer, [swimer.x - @poi.x, swimer.y - @poi.y]])
          end
        end
      end
      @poi.try_catch(catch_objects)
    end

    # swimerに対するメインループ
    @swimers.each do |swimer|
      if not swimer.mode == :catched and not swimer.is_reserved then
        if (swimer.x + swimer.center_x - (@container.x + (@container.width * 0.5))) ** 2 + ((swimer.y + swimer.center_y - (@container.y + (@container.height * 0.5))) ** 2) <= (@container.width * 0.5 * CONTAINER_CONTACT_ADJUST_RANGE_RATIO) ** 2 then
          swimer.z = Z_POSITION_BOTTOM
        else
          swimer.z = Z_POSITION_TOP
        end
      end

      if swimer.is_reserved then
        max_radius = @container.width * 0.5 * CONTAINER_RESERVE_ADJUST_RANGE_RATIO
        obj_radius = Math.sqrt((swimer.x + swimer.center_x - (@container.x + @container.center_x)) ** 2 + ((swimer.y + swimer.center_y - (@container.y + @container.center_y)) ** 2))

        if obj_radius >= max_radius then
          angle = Math.atan2(swimer.y + swimer.center_y - (@container.y + @container.center_y), swimer.x + swimer.center_x - (@container.x + @container.center_x))
          swimer.x = @container.x + @container.center_x - (swimer.width * 0.5) + (max_radius * Math.cos(angle))
          swimer.y = @container.y + @container.center_y - (swimer.height * 0.5) + (max_radius * Math.sin(angle))
        end
      end
    end

=begin
    Sprite.update(@charas)
    Sprite.check(@charas)

    Sprite.check(@item, @charas) if @item
=end

    # Write your code...
    if not @swimers.empty? then
      @swimers.each do |swimer|
        swimer.update
      end
    end

    @poi.update

    Sprite.check(@@borders + @swimers + [@container])
  end

  def render

    # Write your code...
    Window.drawTile(0, 0, [[0]], [@stone_tile_image], nil, nil, nil, nil)
    Window.draw_ex(0, 0, @aquarium_back_image, :alpha=>180)

    @@borders.each do |border|
      border.draw
    end

=begin
    # キャラクタ・スプライトのマウスイベントを処理する場合はコメント外す
    if not @charas.empty? then
      @charas.reverse.each do |obj|
        obj.draw if not obj.nil?
      end
    end
    Sprite.draw(@item) if @item
=end

    @container.draw

    @poi.draw

    if not @swimers.empty? then
      @swimers.each do |swimer|
        swimer.draw
      end
    end

    @exitButton.render
    @windowModeButton.render

    @score_label.render
  end

  # キャラクタ・スプライトのマウスイベントを処理する場合はコメント外す
  def mouseProcess

    # oldX, oldY = @mouse.x, @mouse.y
    @mouse.x, @mouse.y = Input.mouse_pos_x, Input.mouse_pos_y

    if @poi.is_drag then
      @poi.x = @mouse.x - (@poi.width * 0.5)
      @poi.y = @mouse.y - (@poi.height * 0.5)
    end

=begin
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
=end
  end

  def scoring(targets)

    score_diff = 0
    targets.each do |target|
      score_diff += (BASE_SCORES[target.name] * target.height * 0.01).round
    end
    @score += score_diff * targets.size
    @score_label.string = "SCORE : #{@score}点"
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
