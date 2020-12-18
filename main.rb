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
# require "files" # ファイル操作（モジュールなので要include） log.rbを使うときも必要
require "images" # 画像オブジェクト一般
require "common" # Ruby汎用ライブラリ（モジュールなので要include）
# require "excel" # Excel操作用
# require "sqlite3" # データベース
# require "weighted_randomizer" # 重み付き乱択
require "encode" # 文字コード変換
require "json/pure" # JSON
# require "linear_algebra" # 線形代数
# require "win32/open3" # 外部コマンド実行

# Audio解析関連
# require "wav-file"
# require "mciver3"
# require "wav_analyze"

# mp3などを鳴らすため
Dir.chdir("./lib/dxruby") do
  require "Bass"
end

require "stracture"
require "kingyo"
require "poi"
require "container"
require "weed"
require "boss"
require "bgm_info"
require "alert"
require "splash"
require "SampleMapping"
require "name_entry"
require "confetti"
require "score_list_box"

require "net/http"
require "time"

# システム・パラメータ #################################################################################################
# アプリケーション設定
APPLICATION_NAME = "金魚すくい"
APPLICATION_SUB_TITLE = "視線入力対応版"
COPYRIGHT = "Powered by Ruby & DXRuby."
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
MAIN_BGM = "./sounds/minamo.mp3"
ALERT_BGM = "./sounds/nc40157.wav"
BOSS_BGM = "./sounds/boss_panic_big_march.mp3"
SPLASH_SMALL_SE = "./sounds/water-drop3.wav"
SPLASH_RARGE_SE = "./sounds/water-throw-stone2.wav"
CHANGE_STAGE_SE = "./sounds/sei_ge_bubble06.wav"
START_GAME_SE = "./sounds/decision27.wav"
CONGRATULATIONS_SE = "./sounds/nc134713.wav"
NAME_ENTRY_BGM = "./sounds/yuugure.mp3"

# 画像
STONE_TILE_IMAGE = "./images/stone_tile.png"
AQUARIUM_BACK_IMAGE = "./images/seamless-water.jpg"
SPLASH_IMAGE = "./images/water_splash.png"
START_BUTTON_IMAGE = "./images/start_button.png"
NAME_ENTRY_BUTTON_IMAGE = "./images/942037.png"
TITLE_BACK_GROUND_IMAGE = "./images/BG00a1_80a.jpg"
EXIT_BUTTON_IMAGE = "./images/s_3.png"
WINDOW_MODE_BUTTON_IMAGE = "./images/s_2.png"
FLOOR_IMAGE = "./images/floor1.jpg"
RESET_BUTTON_IMAGE = "./images/m_1.png"
DECITION_BUTTON_IMAGE = "./images/m_2.png"
DELETE_BUTTON_IMAGE = "./images/m_3.png"
OK_BUTTON_IMAGE = "./images/m_4.png"

# フォント
TANUKI_MAGIC_FONT = "./fonts/TanukiMagic.ttf"
TANUKI_MAGIC_FONT_TYPE = "たぬき油性マジック"
JIYUNO_TSUBASA_FONT = "./fonts/JiyunoTsubasa.ttf"
JIYUNO_TSUBASA_FONT_TYPE = "自由の翼フォント"
CHECK_POINT_FONT = "./fonts/CP Font.ttf"
CHECK_POINT_FONT_TYPE = "チェックポイントフォント"
LIGHT_NOVEL_POP_FONT = "./fonts/ラノベPOP.otf"
LIGHT_NOVEL_POP_FONT_TYPE = "07ラノベPOP"
AR_KYOUKASYOTAI_M_FONT = "./fonts/JTST00M.TTC"
AR_KYOUKASYOTAI_M_FONT_TYPE = "AR教科書体M"
MIKACHAN_FONT = "./fonts/mikachanALL.ttc"
MIKACHAN_FONT_TYPE = "みかちゃん"

# フォントのインストール
Font.install(TANUKI_MAGIC_FONT)
Font.install(JIYUNO_TSUBASA_FONT)
Font.install(CHECK_POINT_FONT)
Font.install(LIGHT_NOVEL_POP_FONT)
Font.install(AR_KYOUKASYOTAI_M_FONT)
Font.install(MIKACHAN_FONT)
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

DEFAULT_NAME = "名無しさん"
MAX_NAME_INPUT_NUMBER = 8

FIRST_STAGE_NUMBER = 1
FIRST_MODE = :start

Z_POSITION_TOP = 300
Z_POSITION_UP = 200
Z_POSITION_DOWN = 100
Z_POSITION_BOTTOM = 0

KINGYO_NUMBERS = [5]
KINGYO_SCALE_RANGES = [[0.5, 1]]
KINGYO_SPEED_RANGES = [{:wait=>[0, 1], :move=>[1, 5], :escape=>[1, 5]}]
KINGYO_MODE_RANGES = [{:wait=>[0, 100], :move=>[0, 100], :escape=>[0, 100]}]

BOSS_NUMBERS = 1
BOSS_SCALE_RANGES = [0.5, 1]
BOSS_SPEED_RANGES = {:wait=>[0, 1], :move=>[1, 3], :against=>[1, 3]}
BOSS_MODE_RANGES = {:wait=>[0, 200], :move=>[0, 100], :against=>[0, 200]}

WEED_NUMBERS = [1]
WEED_SCALE_RANGES = [[0.4, 0.8]]

POINT_COUNT_IN_WINDOW = 60
POI_CATCH_ADJUST_RANGE_RATIO = 0.9

CONTAINER_CONTACT_ADJUST_RANGE_RATIO = 1.2
CONTAINER_RESERVE_ADJUST_RANGE_RATIO = 0.55

BASE_SCORES = {"red_kingyo"=>100, "black_kingyo"=>50, "weed"=>-150, "boss"=>1000}

TILDE =  "\x81\x60".encode("BINARY")
MAIN_BGM_DATE = ["水面", "Composed by iPad", "しゅんじ" + TILDE]
BOSS_BGM_DATE = ["ボス・パニック大行進", "Composed by iPad", "しゅんじ" + TILDE]

MAIN_ALERT_STRING = "警告！ ボス金魚出現！"
SUB_ALERT_STRING = "WARNING!"

CHALLENGE_POINT_UP_RANGE = 200

START_MAX_COUNT = 180

POI_POINT_COUNT = 30

COMMENDATION_POINT = 0
CONFETTI_MAX_NUMBER = 800

# データベース POST URL
POST_URL = "http://localhost:3000/kingyo_scoopings/record"

# データベース GET URL
GET_URL = "http://localhost:3000/kingyo_scoopings/show"

$name = DEFAULT_NAME
$scores = {:score=>0, :technical_point=>0, :max_combo=>0, :catched_kingyo_number=>0, :catched_boss_number=>0, :total_move_distance=>0}
$cognomens = {:cognomen=>nil, :color=>nil}

Bass.init(Window.hWnd)


# タイトル・シーン
class TitleScene < Scene::Base
  
  def init

    # 必要最小限のグローバル変数を初期化

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

    @clickSE = Sound.new(CLICK_SE)
    @start_game_se = Sound.new(START_GAME_SE)

    background_image = Image.load(TITLE_BACK_GROUND_IMAGE)
    start_button_image = Image.load(START_BUTTON_IMAGE)
    exit_button_image = Image.load(EXIT_BUTTON_IMAGE)
    window_mode_button_image = Image.load(WINDOW_MODE_BUTTON_IMAGE)

    @background_image = RenderTarget.new(Window.width, Window.height).draw_scale(0, 0, background_image, Window.width / background_image.width.to_f, Window.height / background_image.height.to_f, 0, 0).to_image
    background_image.dispose

    @titleLabel = Fonts.new(0, 0, APPLICATION_NAME, Window.height * 0.2, C_RED, 0, "title_label", {:fontType=>CHECK_POINT_FONT_TYPE})
    @sub_title_label = Fonts.new(0, 0, APPLICATION_SUB_TITLE, Window.height * 0.1, C_ORANGE, 0, "sub_title_label", {:fontType=>AR_KYOUKASYOTAI_M_FONT_TYPE})
    @versionNumberLabel = Fonts.new(0, 0, "Version #{VERSION_NUMBER}", @titleLabel.get_height * 0.3, C_GREEN, 0, "version_number_label", {:fontType=>JIYUNO_TSUBASA_FONT_TYPE})
    @copyrightLabel = Fonts.new(0, 0, COPYRIGHT, Window.height * 0.08, C_BLACK, 0, "copyright_label", {:fontType=>LIGHT_NOVEL_POP_FONT_TYPE})

    startButtonHeight = Window.height * 0.06
    start_button_scale = startButtonHeight / start_button_image.height.to_f
    start_button_converted_image = RenderTarget.new(start_button_image.width * start_button_scale, start_button_image.height * start_button_scale).draw_scale(0, 0, start_button_image, start_button_scale, start_button_scale, 0, 0).to_image
    @startButton = Button.new()
    @startButton.name = "start_button"
    @startButton.set_image_and_text(start_button_converted_image)
    start_button_image.dispose

    exitButtonHeight = Window.height * 0.05
    exit_button_scale = exitButtonHeight / exit_button_image.height
    exit_button_converted_image = RenderTarget.new(exit_button_image.width * exit_button_scale, exit_button_image.height * exit_button_scale).draw_scale(0, 0, exit_button_image, exit_button_scale, exit_button_scale, 0, 0).to_image
    @exitButton = Button.new()
    @exitButton.name = "exit_button"
    @exitButton.set_image_and_text(exit_button_converted_image, "Exit", exit_button_converted_image.height * 0.7, C_DARK_BLUE, LIGHT_NOVEL_POP_FONT_TYPE)
    exit_button_image.dispose

    windowModeButtonHeight = Window.height * 0.05
    window_mode_button_scale = windowModeButtonHeight / window_mode_button_image.height
    window_mode_button_converted_image = RenderTarget.new(window_mode_button_image.width * window_mode_button_scale, window_mode_button_image.height * window_mode_button_scale).draw_scale(0, 0, window_mode_button_image, window_mode_button_scale, window_mode_button_scale, 0, 0).to_image
    @windowModeButton = Button.new()
    @windowModeButton.name = "window_mode_button"
    @windowModeButton.set_image_and_text(window_mode_button_converted_image, "Full/Win", window_mode_button_converted_image.height * 0.5, C_DARK_BLUE, LIGHT_NOVEL_POP_FONT_TYPE)
    window_mode_button_image.dispose

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
    @is_start_button_blink = false
    @start_button_blink_count = 0
    @wait_stage_change_count = 0

    @mouse = Sprite.new
    @mouse.collision = [0, 0]

    @poi = Poi.new(0, 0, 0.5, @mouse, nil, self)
    @poi.catch_count = POI_POINT_COUNT

    @buttons = [@startButton, @exitButton, @windowModeButton]
    @windows = []

    self.setPosition
  end

  def setPosition

    @titleLabel.set_pos((Window.width - @titleLabel.get_width) * 0.5, (Window.height - @titleLabel.get_height) * 0.3)
    @versionNumberLabel.set_pos(@titleLabel.x + @titleLabel.get_width - @versionNumberLabel.get_width, @titleLabel.y + @titleLabel.get_height)
    @copyrightLabel.set_pos((Window.width - @copyrightLabel.get_width) * 0.5, (Window.height - @copyrightLabel.get_height) * 0.9)
    @startButton.set_pos((Window.width - @startButton.w) * 0.5, (Window.height - @startButton.h) * 0.7)
    @exitButton.set_pos(Window.width - @exitButton.w, 0)
    @windowModeButton.set_pos(Window.width - (@exitButton.w + @windowModeButton.w), 0)

    2.times do |index|
      @changeWindowSizeLabels[index].set_pos(Window.width * 0.03, Window.height * 0.9 + (Window.height * 0.05 * index))
      @radioButtons[index].setPos(Window.width * 0.01, Window.height * 0.9 + (Window.height * 0.05 * index))
    end

    # Write your code...
    @sub_title_label.set_pos((Window.width - @sub_title_label.get_width) * 0.5, (Window.height - @sub_title_label.get_height) * 0.12)

    @poi.x = (Window.width - @poi.width) * 0.5
    @poi.y = (Window.height - @poi.height) * 0.5
  end

  def update

    if @startButton.pushed? then
      @is_start_button_blink = true unless @is_start_button_blink
      @startButton.isHover = false
      @start_game_se.play
      @wait_stage_change_count = 0
    end

    if @windowModeButton.pushed? then
      if Window.windowed? then
        Window.windowed = false
      else
        Window.windowed = true
      end
      @clickSE.play
    end

    if @exitButton.pushed? or Input.key_push?(K_ESCAPE) then
      self.did_disappear
      exit
    end

    if @buttons and not @buttons.empty? then
      @buttons.each do |button|
        button.hovered?
      end
    end

    # ラジオボタンの排他処理 ##########
    checkID = nil
    for radioButton in @radioButtons do
      if radioButton.checked? then
        @clickSE.play
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
    @mouse.x, @mouse.y = Input.mouse_pos_x, Input.mouse_pos_y

    if @poi and @poi.is_drag then
      @poi.x = @mouse.x - (@poi.width * 0.5)
      @poi.y = @mouse.y - (@poi.height * 0.5)
    end

    if @poi and @poi.mode != :try_gaze then
      if (@windows.size <= POINT_COUNT_IN_WINDOW) then
        mouse_x = @poi.x + (@poi.width * 0.5)
        mouse_y = @poi.y + (@poi.width * 0.5)
        @windows.push([mouse_x, mouse_y])
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

    if @poi and @poi.mode == :try_catch then
      if @buttons and not @buttons.empty? then
        @buttons.each do |button|
          if @mouse.x >= button.x and @mouse.x <= button.x + button.w and @mouse.y >= button.y and @mouse.y <= button.y + button.h then

            case button.name

            when "start_button"
              @is_start_button_blink = true unless @is_start_button_blink
              @startButton.isHover = false
              @start_game_se.play
              @wait_stage_change_count = 0
              @poi.mode = :normal

            when "exit_button"
              self.did_disappear
              exit

            when "window_mode_button"
              if Window.windowed? then
                Window.windowed = false
              else
                Window.windowed = true
              end
              @clickSE.play
              @poi.mode = :normal
            end
          end
        end
      end
    end

    @poi.update if @poi

    if @is_start_button_blink then
      if @start_button_blink_count >= 10 then
        @startButton.blink
        @start_button_blink_count = 0
      else
        @start_button_blink_count += 1
      end
      if @wait_stage_change_count >= 150 then
        self.next_scene = GameScene
        @wait_stage_change_count = 0
      else
        @wait_stage_change_count += 1
      end
    end
  end

  def render

    Window.draw(0, 0, @background_image)
    @titleLabel.render
    @versionNumberLabel.render
    @copyrightLabel.render
    @startButton.render
    @exitButton.render
    @windowModeButton.render

    2.times do |index|
      @radioButtons[index].draw
      @changeWindowSizeLabels[index].render
    end

    # Write your code...
    @sub_title_label.render

    @poi.draw if @poi
  end

  def did_disappear

  end
end


# ゲーム・シーン
class GameScene < Scene::Base

  include Common
  
  def init

    @clickSE = Sound.new(CLICK_SE)
    @change_stage_se = Sound.new(CHANGE_STAGE_SE)
    @splash_small_se = Sound.new(SPLASH_SMALL_SE)
    @splash_rarge_se = Sound.new(SPLASH_RARGE_SE)

    @main_bgm = Bass.loadSample(MAIN_BGM)
    @alert_bgm = Bass.loadSample(ALERT_BGM)
    @boss_bgm = Bass.loadSample(BOSS_BGM)

    exit_button_src_image = Image.load(EXIT_BUTTON_IMAGE)
    window_mode_button_src_image = Image.load(WINDOW_MODE_BUTTON_IMAGE)
    stone_tile_image = Image.load(STONE_TILE_IMAGE)
    aquarium_back_image = Image.load(AQUARIUM_BACK_IMAGE)

    exitButtonHeight = Window.height * 0.05
    exit_button_scale = exitButtonHeight / exit_button_src_image.height
    exit_button_image = RenderTarget.new(exit_button_src_image.width * exit_button_scale, exit_button_src_image.height * exit_button_scale).draw_scale(0, 0, exit_button_src_image, exit_button_scale, exit_button_scale, 0, 0).to_image
    @exitButton = Button.new()
    @exitButton.name = "exit_button"
    @exitButton.set_image_and_text(exit_button_image, "Exit", exit_button_image.height * 0.7, C_DARK_BLUE, LIGHT_NOVEL_POP_FONT_TYPE)
    exit_button_src_image.dispose
    @exitButton.set_pos(Window.width - @exitButton.w, 0)

    windowModeButtonHeight = Window.height * 0.05
    window_mode_button_scale = windowModeButtonHeight / window_mode_button_src_image.height
    window_mode_button_image = RenderTarget.new(window_mode_button_src_image.width * window_mode_button_scale, window_mode_button_src_image.height * window_mode_button_scale).draw_scale(0, 0, window_mode_button_src_image, window_mode_button_scale, window_mode_button_scale, 0, 0).to_image
    @windowModeButton = Button.new()
    @windowModeButton.name = "window_mode_button"
    @windowModeButton.set_image_and_text(window_mode_button_image, "Full/Win", window_mode_button_image.height * 0.5, C_DARK_BLUE, LIGHT_NOVEL_POP_FONT_TYPE)
    window_mode_button_src_image.dispose
    @windowModeButton.set_pos(Window.width - (@exitButton.w + @windowModeButton.w), 0)

    @buttons = [@exitButton, @windowModeButton]

=begin
    # キャラクタ・スプライトのマウスイベントを処理する場合はコメント外す
    # いまマウスで掴んでるオブジェクト
    @item = nil

    # キャラクタをオブジェクト配列に追加
    @charas = [@poi]
=end

    # マウスカーソルの衝突判定用スプライト
    @mouse = Sprite.new
    @mouse.collision = [0, 0]

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
    @score_label = Fonts.new(0, 0, "SCORE : #{@score}点", Window.height * 0.05, C_GREEN, 0, "score_Label", {:fontType=>JIYUNO_TSUBASA_FONT_TYPE})
    @score_label.set_z(Z_POSITION_TOP)

    stone_tile_image_scale = 0.5
    stone_tile_part_rt = RenderTarget.new(stone_tile_image.width * stone_tile_image_scale, stone_tile_image.height * stone_tile_image_scale)
    # おかしいスケーリングでざひょうがへん
    stone_tile_part_rt.draw_scale(stone_tile_image.width * (stone_tile_image_scale - 1.0) * 0.5, stone_tile_image.height * (stone_tile_image_scale - 1.0) * 0.5, stone_tile_image, stone_tile_image_scale, stone_tile_image_scale)
    stone_tile_converted_image = stone_tile_part_rt.to_image
    stone_tile_image.dispose
    stone_tile_part_rt.dispose
    stone_tile_rt = RenderTarget.new(Window.width, Window.height)
    stone_tile_rt.drawTile(0, 0, [[0]], [stone_tile_converted_image], nil, nil, nil, nil)
    @stone_tile_image = stone_tile_rt.to_image
    stone_tile_converted_image.dispose
    stone_tile_rt.dispose

    aquarium_back_rt = RenderTarget.new(Window.width, Window.height)
    aquarium_back_rt.drawTile(0, 0, [[0]], [aquarium_back_image], nil, nil, nil, nil)
    @aquarium_back_image = aquarium_back_rt.to_image
    aquarium_back_image.dispose
    aquarium_back_rt.dispose

    line_width = 50
    border_top = Border.new(0, -1 * line_width, Window.width, line_width, 0)
    border_left = Border.new(-1 * line_width, 0, line_width, Window.height, 1)
    border_right = Border.new(Window.width, 0, line_width, Window.height, 2)
    border_bottom = Border.new(0, Window.height, Window.width, line_width, 3)
    @borders = [border_top, border_left, border_right, border_bottom]

    @container = Container.new(0, 0, 0.8)
    @container.x = 300 # @borders[2].x - @container.width
    @container.y = 300 # @borders[3].y - @container.height
    @container.z = Z_POSITION_DOWN

    @poi = Poi.new(0, 0, 0.8, @mouse, @container, self)
    @poi.x = (Window.width - @poi.width) * 0.5
    @poi.y = (Window.height - @poi.height) * 0.5
    @poi.z = Z_POSITION_TOP

    @windows = []

    @bgm_info = BgmInfo.new(Window.width, Window.height * 0.08, Z_POSITION_TOP)

    @alert = Alert.new(0, 0, Window.width, Window.height)
    @alert.z = Z_POSITION_TOP
    @alert.make_sub_alert(SUB_ALERT_STRING, LIGHT_NOVEL_POP_FONT_TYPE)
    @alert.make_main_alert(MAIN_ALERT_STRING, CHECK_POINT_FONT_TYPE)

    @swimers = []
    @splashs = []

    @challenge_point = 0

    @wave_shader = SampleMappingShader.new
    @shader_rt = RenderTarget.new(Window.width, Window.height)
    @start_count = 0

    @stage_info_label = Fonts.new(0, 0, "", Window.height * 0.2, C_BROWN, 0, "stage_info_label", {:fontType=>LIGHT_NOVEL_POP_FONT_TYPE})

    @stage_number = FIRST_STAGE_NUMBER
    self.change_mode(FIRST_MODE)
  end

  def stage_init

    weeds = []
    WEED_NUMBERS[@stage_number - 1].times do |index|
      weed = Weed.new(0, 0, rand(360), rand_float(WEED_SCALE_RANGES[@stage_number - 1][0], WEED_SCALE_RANGES[@stage_number - 1][1]), index)
      weed.x = random_int(@borders[1].x + @borders[1].width, @borders[2].x - weed.width)
      weed.y = random_int(@borders[0].y + @borders[0].height, @borders[3].y - weed.height)
      weed.z = Z_POSITION_TOP
      weeds.push(weed)
    end

    kingyos = []
    KINGYO_NUMBERS[@stage_number - 1].times do |index|
      kingyo = Kingyo.new(0, 0, KIND_OF_KINGYOS[rand(2)], rand(360), rand_float(KINGYO_SCALE_RANGES[@stage_number - 1][0], KINGYO_SCALE_RANGES[@stage_number - 1][1]), index, KINGYO_SPEED_RANGES[@stage_number - 1], KINGYO_MODE_RANGES[@stage_number - 1])
      kingyo.x = random_int(@borders[1].x + @borders[1].width, @borders[2].x - kingyo.width)
      kingyo.y = random_int(@borders[0].y + @borders[0].height, @borders[3].y - kingyo.height)
      kingyo.z = Z_POSITION_TOP
      kingyos.push(kingyo)
    end

    @swimers = weeds + kingyos
    fisher_yates(@swimers)
  end

  def boss_init

    bosss = []
    BOSS_NUMBERS.times do |index|
      boss = Boss.new(0, 0, rand(360), rand_float(BOSS_SCALE_RANGES[0], BOSS_SCALE_RANGES[1]), index, BOSS_SPEED_RANGES, BOSS_MODE_RANGES)
      boss.x = random_int(@borders[1].x + @borders[1].width, @borders[2].x - boss.width)
      boss.y = random_int(@borders[0].y + @borders[0].height, @borders[3].y - boss.height)
      boss.z = Z_POSITION_TOP
      bosss.push(boss)
    end

    @swimers += bosss
    fisher_yates(@swimers)
  end

  def update

    if @windowModeButton and @windowModeButton.pushed? then
      if Window.windowed? then
        Window.windowed = false
      else
        Window.windowed = true
      end
      @clickSE.play if @clickSE
    end

    if (@exitButton and @exitButton.pushed?) or Input.key_push?(K_ESCAPE) then
      self.did_disappear
      exit
    end

    case @mode

    when :start
      if @start_count < START_MAX_COUNT then
        @wave_shader.update if @wave_shader
        @start_count += 1
      else
        self.change_mode(:normal)
      end
    end

    # キャラクタ・スプライトのマウスイベントを処理する場合はコメント外す
    self.mouseProcess if @mouse

    if @poi and @poi.mode != :try_gaze and @poi.mode != :transport then
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

    if @poi and @poi.mode == :try_catch and not @mode == :start then
      catch_objects = []

      if @swimers and not @swimers.empty? then
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

      if @buttons and not @buttons.empty? then
        @buttons.each do |button|
          if @mouse.x >= button.x and @mouse.x <= button.x + button.w and @mouse.y >= button.y and @mouse.y <= button.y + button.h then

            case button.name

            when "exit_button"
              self.did_disappear
              exit

            when "window_mode_button"
              if Window.windowed? then
                Window.windowed = false
              else
                Window.windowed = true
              end
              @clickSE.play
              @poi.mode = :normal
            end
          end
        end
      end
    end

    # swimerに対するメインループ
    if @swimers and not @swimers.empty? and not @mode == :start
    @swimers.each do |swimer|
        if not swimer.mode == :catched and not swimer.is_reserved then
          if (swimer.x + swimer.center_x - (@container.x + (@container.width * 0.5))) ** 2 + ((swimer.y + swimer.center_y - (@container.y + (@container.height * 0.5))) ** 2) <= (@container.width * 0.5 * CONTAINER_CONTACT_ADJUST_RANGE_RATIO) ** 2 then
            swimer.z = Z_POSITION_BOTTOM
          else
            swimer.z = Z_POSITION_TOP
          end
        end

        if swimer.mode == :reserved then
          splash = Splash.new(SPLASH_IMAGE, 10, 1)
          splash.run(swimer.x + swimer.center_x - (splash.width * 0.5), swimer.y + swimer.center_y - (splash.height * 0.5), swimer, swimer.height * 2.0, 0.8)
          if swimer.name == "boss" then
            @splash_rarge_se.play
          else
            @splash_small_se.play
          end
          @splashs.push(splash)
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
    end

    if @splashs and not @splashs.empty? and not @mode == :start
      @splashs.each do |splash|
        if splash.mode == :finish then
          @splashs.delete(splash)
        else
          splash.update
        end
      end
    end

    @bgm_info.update if @bgm_info and @bgm_info.mode == :run and not @mode == :start

    if @alert and @alert.mode == :run and not @mode == :start then
      @alert.update
    elsif @alert and @alert.mode == :finish
      @alert.mode = :wait
      self.change_mode(:boss)
    end

=begin
    Sprite.update(@charas)
    Sprite.check(@charas)

    Sprite.check(@item, @charas) if @item
=end

    # Write your code...
    if @swimers and not @swimers.empty? and not @mode == :start then
      @swimers.each do |swimer|
        swimer.update
      end
    end

    @poi.update if @poi

    Sprite.check(@borders + @swimers + [@container]) if @borders and not @borders.empty? and @swimers and not @swimers.empty? and @container and not @mode == :start
  end

  def render

    # Write your code...
    Window.draw(0, 0, @stone_tile_image) if @stone_tile_image
    Window.draw_ex(0, 0, @aquarium_back_image, :alpha=>180) if @aquarium_back_image

    @shader_rt.draw(0, 0, @aquarium_back_image) if @mode == :start
    Window.draw_shader(0, 0, @shader_rt, @wave_shader) if @mode == :start

    @stage_info_label.render if @mode == :start

    if @borders and not @borders.empty? and not @mode == :start
      @borders.each do |border|
        border.draw
      end
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

    @container.draw if @container and not @mode == :start
    @poi.draw if @poi

    if @swimers and not @swimers.empty? and not @mode == :start then
      @swimers.each do |swimer|
        swimer.draw if not swimer.name == "boss" or not @mode == :alert
      end
    end

    if @splashs and not @splashs.empty? and not @mode == :start
      @splashs.each do |splash|
        splash.draw
      end
    end

    @exitButton.render
    @windowModeButton.render

    @score_label.render if @score_label and not @mode == :start
    @bgm_info.draw if @bgm_info and @bgm_info.mode == :run and not @mode == :start
    @alert.draw if @alert and @alert.mode == :run and not @mode == :start
  end

  # キャラクタ・スプライトのマウスイベントを処理する場合はコメント外す
  def mouseProcess

    # oldX, oldY = @mouse.x, @mouse.y
    @mouse.x, @mouse.y = Input.mouse_pos_x, Input.mouse_pos_y

    if @poi and @poi.is_drag then
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

  def change_mode(mode)

    case mode

    when :start

      @change_stage_se.play if @change_stage_se
      self.stage_init

      @stage_info_label.string = "ステージ#{@stage_number}"
      @stage_info_label.x = (Window.width - @stage_info_label.get_width) * 0.5
      @stage_info_label.y = (Window.height - @stage_info_label.get_height) * 0.5

    when :normal

      if @bgm then
        @bgm.stop
      end
      @bgm = @main_bgm
      @bgm.play(:loop=>true, :volume=>0.5)
      @bgm_info.set_info({:title=>MAIN_BGM_DATE[0], :data=>MAIN_BGM_DATE[1], :copyright=>MAIN_BGM_DATE[2]}, {:title=>TANUKI_MAGIC_FONT_TYPE, :data=>TANUKI_MAGIC_FONT_TYPE, :copyright=>TANUKI_MAGIC_FONT_TYPE}, font_color={:title=>C_WHITE, :data=>C_WHITE, :copyright=>C_WHITE}, font_size={:title=>32, :data=>24, :copyright=>28})
      @bgm_info.mode = :run

    when :alert

      @alert.mode = :run
      if @bgm then
        @bgm.stop
      end
      @bgm = @alert_bgm
      @bgm.play(:loop=>true, :volume=>0.5)

      self.boss_init

    when :boss

      if @bgm then
        @bgm.stop
      end
      @bgm = @boss_bgm
      @bgm.play(:loop=>true, :volume=>0.5)
      @bgm_info.set_info({:title=>BOSS_BGM_DATE[0], :data=>BOSS_BGM_DATE[1], :copyright=>BOSS_BGM_DATE[2]}, {:title=>TANUKI_MAGIC_FONT_TYPE, :data=>TANUKI_MAGIC_FONT_TYPE, :copyright=>TANUKI_MAGIC_FONT_TYPE}, font_color={:title=>C_WHITE, :data=>C_WHITE, :copyright=>C_WHITE}, font_size={:title=>24, :data=>24, :copyright=>28})
      @bgm_info.mode = :run
    end

    @mode = mode
  end

  def scoring(targets)

    score_diff = 0
    technical_point_diff = 0

    targets.each do |target|
      score_diff += (BASE_SCORES[target.name] * target.height * 0.01).round
    end
    $scores[:score] += score_diff * targets.size
    @score_label.string = "SCORE : #{$scores[:score]}点"

    technical_point_diff += 50
    $scores[:technical_point] += technical_point_diff

    @challenge_point += technical_point_diff
    boss_remaind_numbes = @swimers.select { |obj| obj.name == "boss" and not obj.is_reserved}
    if @challenge_point >= CHALLENGE_POINT_UP_RANGE and not @mode == :alert and boss_remaind_numbes.empty? then
      self.change_mode(:alert)
      @challenge_point = 0
    end

    if @swimers.select { |obj| not obj.is_reserved and not obj.name == "weed"}.empty? then
      @mode = :game_over
      $scores[:max_combo] = 0
      $scores[:catched_kingyo_number] = 0
      $scores[:catched_boss_number] = 0
      $scores[:total_move_distance] = 0
      self.did_disappear
      self.next_scene = ResultScene
    end

  end

  def did_disappear
    if @bgm then
      @bgm.stop
      @bgm.free
      # Bass.free
    end
  end
end


class ResultScene < Scene::Base

  def init

    @clickSE = Sound.new(CLICK_SE)
    ok_button_image = Image.load(OK_BUTTON_IMAGE)

    @congratulations_se = Sound.new(CONGRATULATIONS_SE)
    @background = Image.new(Window.width, Window.height).box_fill(0, 0, Window.width, Window.height, C_MISTY_ROSE)

    technical_point = $scores[:technical_point]
    $cognomens[:cognomen], $cognomens[:color] = "ウンコちゃん", C_BROWN if technical_point < 500
    $cognomens[:cognomen], $cognomens[:color] = "ザコりん", C_CYAN if technical_point >= 500 and technical_point < 1000
    $cognomens[:cognomen], $cognomens[:color] = "初心者ペー", C_YELLOW if technical_point >= 1000 and technical_point < 2000
    $cognomens[:cognomen], $cognomens[:color] = "普通ヲタ", C_GREEN if technical_point >= 2000 and technical_point < 3000
    $cognomens[:cognomen], $cognomens[:color] = "良しヲくん", C_ORANGE if technical_point >= 3000 and technical_point < 4000
    $cognomens[:cognomen], $cognomens[:color] = "スーパーカブ", C_MAGENTA if technical_point >= 4000 and technical_point < 5000
    $cognomens[:cognomen], $cognomens[:color] = "レジェンドン", C_BLUE if technical_point >= 5000 and technical_point < 6000
    $cognomens[:cognomen], $cognomens[:color] = "金魚人", C_PURPLE if technical_point >= 6000 and technical_point < 7000
    $cognomens[:cognomen], $cognomens[:color] = "金魚神", C_RED if technical_point >= 7000

    @titleLabel = Fonts.new(0, 0, "結果", Window.height * 0.1, C_PURPLE, 0, "title_label", {:fontType=>CHECK_POINT_FONT_TYPE})
    @titleLabel.set_pos((Window.width - @titleLabel.get_width) * 0.5, Window.height * 0.03)

    @score_label = Fonts.new(0, 0, "SCORE : #{$scores[:score]}点", Window.height * 0.05, C_GREEN, 0, "score_label", {:fontType=>JIYUNO_TSUBASA_FONT_TYPE})
    @score_label.set_pos((Window.width - @score_label.get_width) * 0.5, Window.height * 0.15)

    @catched_kingyo_number_label = Fonts.new(0, 0, "金魚捕獲数 : #{$scores[:catched_kingyo_number]}匹", Window.height * 0.07, C_RED, 0, "catched_kingyo_number_label", {:fontType=>JIYUNO_TSUBASA_FONT_TYPE})
    @catched_kingyo_number_label.set_pos((Window.width - @catched_kingyo_number_label.get_width) * 0.5, Window.height * 0.23)

    @catched_boss_number_label = Fonts.new(0, 0, "ボス捕獲数 : #{$scores[:catched_boss_number]}匹", Window.height * 0.07, C_RED, 0, "catched_boss_number_label", {:fontType=>JIYUNO_TSUBASA_FONT_TYPE})
    @catched_boss_number_label.set_pos((Window.width - @catched_boss_number_label.get_width) * 0.5, Window.height * 0.33)

    @max_combo_label = Fonts.new(0, 0, "MAXコンボ : #{$scores[:max_combo]}", Window.height * 0.07, C_ORANGE, 0, "max_combo_label", {:fontType=>JIYUNO_TSUBASA_FONT_TYPE})
    @max_combo_label.set_pos((Window.width - @max_combo_label.get_width) * 0.5, Window.height * 0.43)

    @total_move_distance_label = Fonts.new(0, 0, "総移動距離 : #{$scores[:total_move_distance]}m", Window.height * 0.07, C_GRAY, 0, "total_move_distance_label", {:fontType=>JIYUNO_TSUBASA_FONT_TYPE})
    @total_move_distance_label.set_pos((Window.width - @total_move_distance_label.get_width) * 0.5, Window.height * 0.53)

    @technical_point_label = Fonts.new(0, 0, "テクニカルポイント : #{$scores[:technical_point]}", Window.height * 0.05, C_DARK_BLUE, 0, "technical_point_label", {:fontType=>JIYUNO_TSUBASA_FONT_TYPE})
    @technical_point_label.set_pos((Window.width - @technical_point_label.get_width) * 0.5, Window.height * 0.63)

    @cognomen_label = Fonts.new(0, 0, "称号 : #{$cognomens[:cognomen]}", Window.height * 0.1, $cognomens[:color], 0, "cognomen_label", {:fontType=>TANUKI_MAGIC_FONT_TYPE})
    @cognomen_label.set_pos((Window.width - @cognomen_label.get_width) * 0.5, Window.height * 0.71)
    @cognomen_label.isBold = true

    ok_button_width_scale = Window.width * 0.2 / ok_button_image.width
    ok_button_height_scale = Window.height * 0.1 / ok_button_image.height
    @ok_button = Button.new(Window.width * 0.4, Window.height * 0.85)
    @ok_button.name = "ok_button"
    ok_button_converted_image = RenderTarget.new(Window.width * 0.2, Window.height * 0.1).draw_scale(0, 0, ok_button_image, ok_button_width_scale, ok_button_height_scale, 0, 0).to_image
    @ok_button.set_image_and_text(ok_button_converted_image, text="OK", ok_button_converted_image.height * 0.8, C_MIKUSAN, LIGHT_NOVEL_POP_FONT_TYPE)
    ok_button_image.dispose

    if technical_point >= COMMENDATION_POINT then
      confetti_size_min = Window.height * 0.03
      confetti_size_max = confetti_size_min * 3
      confetti_accel_min = 0.02
      confetti_accel_max = confetti_accel_min * 4
      confetti_amp_min = Window.height * 0.005
      confetti_amp_max = confetti_amp_min * 2
      confetti_rot_speed_min = 0.5
      confetti_rot_speed_max = confetti_rot_speed_min * 15
      confetti_angular_velo_min = 0.5
      confetti_angular_velo_max = confetti_angular_velo_min * 10

      @confettis = []
      CONFETTI_MAX_NUMBER.times do
        confetti = Confetti.new(Window.height, [0, 0], [0, 0], [confetti_size_min, confetti_size_max],
                                [confetti_accel_min, confetti_accel_max], [confetti_amp_min, confetti_amp_max],
                                [confetti_rot_speed_min, confetti_rot_speed_max], [confetti_angular_velo_min, confetti_angular_velo_max])
        confetti.set_x([-1 * confetti.width * Math.sqrt(2), Window.width + (confetti.width * Math.sqrt(2))])
        confetti.set_y([-1 * confetti.width * Math.sqrt(2), -2 * (Window.width + (confetti.width * Math.sqrt(2)))])
        @confettis.push(confetti)
      end
      @congratulations_se.play
    end
  end

  def update

    if @confettis and not @confettis.empty? then
      @confettis.each do |confetti|
        confetti.update
      end
    end

    if @ok_button.pushed? then
      @clickSE.play
      self.next_scene = NameEntryScene
    end
    @ok_button.hovered?
  end

  def render

    Window.draw(0, 0, @background) if @background

    if @confettis and not @confettis.empty? then
      @confettis.each do |confetti|
        confetti.draw
      end
    end

    @titleLabel.render
    @score_label.render
    @catched_kingyo_number_label.render
    @catched_boss_number_label.render
    @max_combo_label.render
    @total_move_distance_label.render
    @technical_point_label.render
    @cognomen_label.render
    @ok_button.render
  end
end


class NameEntryScene < Scene::Base

  def init

    @clickSE = Sound.new(CLICK_SE)
    @bgm = Bass.loadSample(NAME_ENTRY_BGM)

    floor_image = Image.load(FLOOR_IMAGE)
    reset_button_image = Image.load(RESET_BUTTON_IMAGE)
    decision_button_image = Image.load(DECITION_BUTTON_IMAGE)
    delete_button_image = Image.load(DELETE_BUTTON_IMAGE)
    name_entry_button_image = Image.load(NAME_ENTRY_BUTTON_IMAGE)

    exit_button_image = Image.load(EXIT_BUTTON_IMAGE)
    window_mode_button_image = Image.load(WINDOW_MODE_BUTTON_IMAGE)

    floor_image_scale = 1.0
    floor_src_rt = RenderTarget.new(floor_image.width * floor_image_scale, floor_image.height * floor_image_scale)
    floor_src_rt.draw_scale(0, 0, floor_image, floor_image_scale, floor_image_scale)
    floor_src_image = floor_src_rt.to_image
    floor_image.dispose
    floor_src_rt.dispose
    floor_rt = RenderTarget.new(Window.width, Window.height)
    floor_rt.drawTile(0, 0, [[0]], [floor_src_image], nil, nil, nil, nil)
    @floor_image = floor_rt.to_image
    floor_src_image.dispose
    floor_rt.dispose

    @titleLabel = Fonts.new(0, 0, "名前の入力", Window.height * 0.05, C_BLACK)
    @titleLabel.set_pos((Window.width - @titleLabel.get_width) * 0.5, Window.height * 0.06 - (@titleLabel.get_height * 0.5))
    @titleLabel.fontType = LIGHT_NOVEL_POP_FONT_TYPE

    @scoreLabel = Fonts.new(0, 0, "SCORE : #{$scores[:score]}点", Window.height * 0.07, C_GREEN)
    @scoreLabel.set_pos((Window.width - @scoreLabel.get_width) * 0.5, Window.height * 0.13 - (@scoreLabel.get_height * 0.5))
    @scoreLabel.fontType = JIYUNO_TSUBASA_FONT_TYPE

    @inputBox = Images.new(Window.width * 0.3, Window.height * 0.18, Window.width * 0.4, Window.height * 0.13, "")
    @inputBox.fontSize = @inputBox.w * 0.12
    @inputBox.string_pos("", @inputBox.font_size, (@inputBox.w - (@inputBox.font_size * MAX_NAME_INPUT_NUMBER)) * 0.5, (@inputBox.h - @inputBox.font_size) * 0.5, C_BLACK)
    @inputBox.fontType = AR_KYOUKASYOTAI_M_FONT_TYPE
    @inputBox.frame(C_BROWN, @inputBox.h * 0.05)

    exitButtonHeight = Window.height * 0.05
    exit_button_scale = exitButtonHeight / exit_button_image.height
    exit_button_converted_image = RenderTarget.new(exit_button_image.width * exit_button_scale, exit_button_image.height * exit_button_scale).draw_scale(0, 0, exit_button_image, exit_button_scale, exit_button_scale, 0, 0).to_image
    @exitButton = Button.new()
    @exitButton.name = "exit_button"
    @exitButton.set_image_and_text(exit_button_converted_image, "Exit", exit_button_converted_image.height * 0.7, C_DARK_BLUE, LIGHT_NOVEL_POP_FONT_TYPE)
    exit_button_image.dispose
    @exitButton.set_pos(Window.width - @exitButton.w, 0)

    windowModeButtonHeight = Window.height * 0.05
    window_mode_button_scale = windowModeButtonHeight / window_mode_button_image.height
    window_mode_button_converted_image = RenderTarget.new(window_mode_button_image.width * window_mode_button_scale, window_mode_button_image.height * window_mode_button_scale).draw_scale(0, 0, window_mode_button_image, window_mode_button_scale, window_mode_button_scale, 0, 0).to_image
    @windowModeButton = Button.new()
    @windowModeButton.name = "window_mode_button"
    @windowModeButton.set_image_and_text(window_mode_button_converted_image, "Full/Win", window_mode_button_converted_image.height * 0.5, C_DARK_BLUE, LIGHT_NOVEL_POP_FONT_TYPE)
    window_mode_button_image.dispose
    @windowModeButton.set_pos(Window.width - (@exitButton.w + @windowModeButton.w), 0)

    name_entry_buttons_size = Window.height * 0.1
    name_entry_buttons_font_size = name_entry_buttons_size * 0.8
    name_entry_button_width_scale = name_entry_buttons_size / name_entry_button_image.width
    name_entry_button_height_scale = name_entry_buttons_size / name_entry_button_image.height
    name_entry_button_coverted_image = RenderTarget.new(name_entry_buttons_size, name_entry_buttons_size).draw_scale(0, 0, name_entry_button_image, name_entry_button_width_scale, name_entry_button_height_scale, 0, 0).to_image
    @nameEntry = NameEntry.new(0, 0, name_entry_buttons_size, name_entry_buttons_size, name_entry_buttons_font_size, C_BROWN, C_WHITE, {:fontType=>MIKACHAN_FONT_TYPE})
    @nameEntry.setPos((Window.width - @nameEntry.width) * 0.5, (Window.height - @nameEntry.height) * 0.65)
    @nameEntry.set_image_object(name_entry_button_coverted_image)
    name_entry_button_image.dispose

    decision_button_width_scale = Window.width * 0.2 / decision_button_image.width
    decision_button_height_scale = Window.height * 0.1 / decision_button_image.height
    @decisionButton = Button.new(Window.width * 0.4, Window.height * 0.85)
    @decisionButton.name = "decision_button"
    decision_button_converted_image = RenderTarget.new(Window.width * 0.2, Window.height * 0.1).draw_scale(0, 0, decision_button_image, decision_button_width_scale, decision_button_height_scale, 0, 0).to_image
    @decisionButton.set_image_and_text(decision_button_converted_image, text="決定", decision_button_converted_image.height * 0.8, C_BLACK, LIGHT_NOVEL_POP_FONT_TYPE)
    decision_button_image.dispose

    reset_button_width_scale = Window.width * 0.2 / reset_button_image.width
    reset_button_height_scale = Window.height * 0.1 / reset_button_image.height
    @resetButton = Button.new(Window.width * 0.2, Window.height * 0.85, Window.width * 0.2)
    @resetButton.name = "reset_button"
    reset_button_converted_image = RenderTarget.new(Window.width * 0.2, Window.height * 0.1).draw_scale(0, 0, reset_button_image, reset_button_width_scale, reset_button_height_scale, 0, 0).to_image
    @resetButton.set_image_and_text(reset_button_converted_image, text="リセット", reset_button_converted_image.height * 0.8, C_BLACK, LIGHT_NOVEL_POP_FONT_TYPE)

    delete_button_width_scale = Window.width * 0.2 / delete_button_image.width
    delete_button_height_scale = Window.height * 0.1 / delete_button_image.height
    @deleteButton = Button.new(Window.width * 0.6, Window.height * 0.85, Window.width * 0.2)
    @deleteButton.name = "delete_button"
    delete_button_converted_image = RenderTarget.new(Window.width * 0.2, Window.height * 0.1).draw_scale(0, 0, delete_button_image, delete_button_width_scale, delete_button_height_scale, 0, 0).to_image
    @deleteButton.set_image_and_text(delete_button_converted_image, text="一文字消す",delete_button_converted_image.height * 0.8, C_BLACK, LIGHT_NOVEL_POP_FONT_TYPE)

    @buttons = [@windowModeButton, @exitButton, @decisionButton, @resetButton, @deleteButton]

    @inputBox.string = $name

    @mouse = Sprite.new
    @mouse.collision = [0, 0]

    @poi = Poi.new(0, 0, 0.5, @mouse, nil, self)
    @poi.catch_count = POI_POINT_COUNT

    @windows = []

    @bgm.play(:loop=>true, :volume=>0.5)
  end

  def update

    if @windowModeButton.pushed? then
      if Window.windowed? then
        Window.windowed = false
      else
        Window.windowed = true
      end
      @clickSE.play
    end

    if @exitButton.pushed? then
      exit
    end

    @nameEntry.kanaButtons.each do |kanaButton|
      if kanaButton.pushed? then
        @clickSE.play
        if $name.size < MAX_NAME_INPUT_NUMBER * 2 then
          $name += kanaButton.text
          @inputBox.string = $name
        end
      end
      kanaButton.hovered?
    end

    if @decisionButton.pushed? then
      @clickSE.play
      self.did_disappear
      self.sendToDatabase
      self.next_scene = RankingScene
    end

    if @resetButton.pushed? then
      @clickSE.play
      $name = ""
      @inputBox.string = $name
    end

    if @deleteButton.pushed? then
      @clickSE.play
      if $name.size > 0 then
        $name.chop!
        @inputBox.string = $name
      end
    end

    if @buttons and not @buttons.empty? then
      @buttons.each do |button|
        button.hovered?
      end
    end

    @mouse.x, @mouse.y = Input.mouse_pos_x, Input.mouse_pos_y

    if @poi and @poi.is_drag then
      @poi.x = @mouse.x - (@poi.width * 0.5)
      @poi.y = @mouse.y - (@poi.height * 0.5)
    end

    if @poi and @poi.mode != :try_gaze then
      if (@windows.size <= POINT_COUNT_IN_WINDOW) then
        mouse_x = @poi.x + (@poi.width * 0.5)
        mouse_y = @poi.y + (@poi.width * 0.5)
        @windows.push([mouse_x, mouse_y])
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

    if @poi and @poi.mode == :try_catch then
      if @nameEntry and not @nameEntry.kanaButtons.empty? then
        @nameEntry.kanaButtons.each do |kanaButton|
          if @mouse.x >= kanaButton.x and @mouse.x <= kanaButton.x + kanaButton.w and @mouse.y >= kanaButton.y and @mouse.y <= kanaButton.y + kanaButton.h then
            @clickSE.play
            if $name.size < MAX_NAME_INPUT_NUMBER * 2 then
              $name += kanaButton.text
              @inputBox.string = $name
            end
          end
        end
      end

      if @buttons and not @buttons.empty? then
        @buttons.each do |button|
          if @mouse.x >= button.x and @mouse.x <= button.x + button.w and @mouse.y >= button.y and @mouse.y <= button.y + button.h then

            case button.name

            when "exit_button"
              self.did_disappear
              exit

            when "window_mode_button"
              if Window.windowed? then
                Window.windowed = false
              else
                Window.windowed = true
              end
              @clickSE.play
              @poi.mode = :normal

            when "decision_button"
              @clickSE.play
              self.did_disappear
              # self.sendToDatabase
              self.next_scene = RankingScene

            when "reset_button"
              @clickSE.play
              $name = ""
              @inputBox.string = $name

            when "delete_button"
              @clickSE.play
              if $name.size > 0 then
                $name.chop!
                @inputBox.string = $name
              end
            end
          end
        end
      end
      @poi.mode = :normal
    end

    @poi.update if @poi
  end

  def render
    Window.draw(0, 0, @floor_image) if @floor_image
    @titleLabel.render
    @scoreLabel.render
    @exitButton.render
    @windowModeButton.render
    @nameEntry.draw
    @inputBox.render
    @decisionButton.render
    @resetButton.render
    @deleteButton.render

    @poi.draw if @poi
  end

  def sendToDatabase

    uri = URI.parse(POST_URL)
    http = Net::HTTP.new(uri.host, uri.port)

    req = Net::HTTP::Post.new(uri.path)
    req.set_form_data({:name=>$name.encode("UTF-8"), :score=>$scores[:score],
                       :cognomen=>$cognomens[:cognomen], :cognomen_color=>$cognomens[:color]})

    http.request(req)
  end

  def did_disappear
    if @bgm then
      @bgm.stop
      @bgm.free
    end
  end
end


class RankingScene < Scene::Base

  def init

    @titleLabel = Fonts.new(0, 0, "ランキング・TOP10", Window.height * 0.07, C_BLACK)
    @titleLabel.set_pos((Window.width - @titleLabel.get_width) * 0.5, Window.height * 0.07 - (@titleLabel.get_height * 0.5))
    @titleLabel.fontType = "みかちゃん"

    exitButtonText = "Exit"
    exitButtonHeight = Window.height * 0.03
    @exitButton = Button.new(0, 0, exitButtonHeight * exitButtonText.size * 0.5, exitButtonHeight, exitButtonText, exitButtonHeight)
    @exitButton.set_pos(Window.width - @exitButton.w, 0)

    windowModeButtonText = "Full/Window"
    windowModeButtonHeight = Window.height * 0.03
    @windowModeButton = Button.new(0, 0, windowModeButtonHeight * windowModeButtonText.size * 0.5, windowModeButtonHeight, windowModeButtonText, windowModeButtonHeight)
    @windowModeButton.set_pos(Window.width - (@exitButton.w + @windowModeButton.w), 0)

    @returnButton = Button.new(Window.width * 0.4, Window.height * 0.87, Window.width * 0.2, Window.height * 0.1, "タイトルに戻る")

    @clickSE = Sound.new(CLICK_SE)

    # self.makeResultLabel
    self.temp
  end

  def temp
    items = [["1位", "非常勤講師", "10000点", "金魚神"], ["2位", "アルバイト募集", "1000点", "金魚人"], ["3位", "ちづる", "100点", "レジェンドン"],
             ["4位", "神じゃね？", "10点", "スーパーカブ"], ["5位", "落ちこぼれ野郎", "1点", "良しヲくん"],["6位", "非常勤講師", "10000点", "金魚神"],
             ["7位", "アルバイト募集", "1000点", "金魚人"], ["8位", "ちづる", "100点", "レジェンドン"], ["9位", "神じゃね？", "10点", "スーパーカブ"],
             ["10位", "落ちこぼれ野郎", "1点", "良しヲくん"], ["11位", "非常勤講師", "10000点", "金魚神"], ["12位", "アルバイト募集", "1000点", "金魚人"],
             ["13位", "ちづる", "100点", "レジェンドン"], ["14位", "神じゃね？", "10点", "スーパーカブ"], ["100位", "落ちこぼれ野郎乙", "100000000点", "良しヲくん"]]
    colors = [C_RED, C_PURPLE, C_BLUE, C_MAGENTA, C_ORANGE, C_RED, C_PURPLE, C_BLUE, C_MAGENTA, C_ORANGE,
              C_RED, C_PURPLE, C_BLUE, C_MAGENTA, C_ORANGE, C_RED, C_PURPLE, C_BLUE, C_MAGENTA, C_ORANGE, C_RED, C_PURPLE, C_BLUE, C_MAGENTA, C_ORANGE]

    @list_box = ScoreListBox.new(250, 150, Window.width - 500, Window.height - 350)
    @list_box.set_items(items, [3, 8, 7, 4], C_ROYAL_BLUE, colors, 3)
  end

  def loadFromDatabase

    uri = URI.parse(GET_URL)

    # 第2引数にHashを指定することでPOSTする際のデータを指定出来る
    response = Net::HTTP.post_form(uri, {})

    jsons = JSON.parse(response.body)

    raws = []
    results = []

    for json in jsons do
      raws << json["name"].to_s.encode("Shift_JIS")
      raws << json["score"].to_s
      raws << Time.parse(json["created_at"]).strftime("%Y-%m-%d %H:%M:%S")
      results << raws
      raws = []
    end
    return results
  end

  def makeResultLabel

    resultsRectSize = [Window.width * 0.9, Window.height * 0.7]
    resultsRectPosition = [(Window.width - resultsRectSize[0]) * 0.5, (Window.height - resultsRectSize[1]) * 0.5]

    resurtsFontSize = Window.width * 0.03

    # results = loadFromDatabase
    results = [["名無しさん", 1234, "2020-07-27 12:12:12"]]

    @rankLabels = []
    @nameLabels = []
    @scoreLabels = []
    @datetimeLabels = []

    for loopID in 0...results.size do

      rankLabel = Fonts.new(resultsRectPosition[0], resultsRectPosition[1] + (resultsRectSize[1] * 0.1 * loopID), "#{loopID + 1}位", resurtsFontSize, C_BLACK)
      nameLabel = Fonts.new(resultsRectPosition[0] + resultsRectSize[0] * 0.15, resultsRectPosition[1] + (resultsRectSize[1] * 0.1 * loopID), results[loopID][0], resurtsFontSize, C_BLACK)
      scoreLabel = Fonts.new(resultsRectPosition[0] + resultsRectSize[0] * 0.45, resultsRectPosition[1] + (resultsRectSize[1] * 0.1 * loopID), results[loopID][1], resurtsFontSize, C_BLACK)
      datetimeLabel = Fonts.new(resultsRectPosition[0] + resultsRectSize[0] * 0.65, resultsRectPosition[1] + (resultsRectSize[1] * 0.1 * loopID), results[loopID][2], resurtsFontSize, C_BLACK)

      @rankLabels << rankLabel
      @nameLabels << nameLabel
      @scoreLabels << scoreLabel
      @datetimeLabels << datetimeLabel
    end
  end

  def update

    if @windowModeButton.pushed? then
      if Window.windowed? then
        Window.windowed = false
      else
        Window.windowed = true
      end
      @clickSE.play
    end

    if @exitButton.pushed? then
      exit
    end

    if @returnButton.pushed? then
      @clickSE.play
      self.next_scene = TitleScene
    end

    @list_box.update
    if Input.key_push?(K_UP) then
      @list_box.scroll_up
    end
    if Input.key_push?(K_DOWN) then
      @list_box.scroll_down
    end
  end

  def render
    @list_box.draw

    @titleLabel.render
    @exitButton.render
    @windowModeButton.render
    @returnButton.render

    if @rankLabels and not @rankLabels.empty? then
      for rankLabel in @rankLabels do
        rankLabel.render
      end
    end

    if @nameLabels and not @nameLabels.empty? then
      for nameLabel in @nameLabels do
        nameLabel.render
      end
    end

    if @scoreLabels and not @scoreLabels.empty? then
      for scoreLabel in @scoreLabels do
        scoreLabel.render
      end
    end

    if @datetimeLabels and not @datetimeLabels.empty? then
      for datetimeLabel in @datetimeLabels do
        datetimeLabel.render
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
