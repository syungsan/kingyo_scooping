#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE= "s"
require "jcode"

# common.rb Ver 1.2
# Ruby汎用ライブラリ

require "Win32API"
require "win32ole"


module Common

  # スレッド停止処理
  def kill_thread (t_name) # 引数 - スレッド・オブジェクト
    Thread.kill(t_name)
  end

  # ランダム少数値生成（minとmax）
  def rand_float(min, max) # 引数 - Int型の最小値と最大値
    return rand() * (max - min) + min
  end

  # 範囲内のランダムな整数を生成
  def random_int(min, max)
    return rand(max - min) + min
  end

  # 配列の要素の重複のあるすべての順序付き組み合わせを返す
  def all_rep_permu(array) # 引数 - 配列
    all_rep_permu = []
    array.count.times{|i| all_rep_permu += array.repeated_permutation(i + 1).to_a.collect{|a| a.join}}
    return all_rep_permu
  end

  # 0からdivを境として周期的に正負交互の符号を返す関数（境界条件関数）
  def gen_sign(cnt, div) # 引数 -> cntは連続カウント，divは境界値
    count = (div - 2).div(4) - cnt # 初項の修正
    y = Math.sin(Math::PI / (div - 1) * count + Math::PI / 4) # 位相
    return y <=> 0 # 符号を返す関数（sign）
  end

  # 一次元配列シャッフルの最強アルゴリズム（"フィッシャー・ヤッテ"のアルゴリズム）
  def fisher_yates(items) # 引数 - 配列
    for i in (items.length-1).downto(0)
      j = rand(i + 1)
      temp = items[i]
      items[i] = items[j]
      items[j] = temp
    end
  end

  @beep = Win32API.new("kernel32", "Beep", %w(l l), 'l')

  def play_beep

    begin
      @beep.call(304, 250) # beep関数の呼び出し。304は周波数、250は音の長さ。
    rescue
      @beep = Win32API.new("kernel32", "Beep", %w(l l), 'l')
      retry
    end
  end

  # ファイル名に使えない文字列が含まれていないかチェック
  def check_input_box(name)

    strings = name.split(//)

    risk = ["\\", "/", ":", "*", "?", '"', "<", ">", "|"]
    flag = true

    strings.map{ |letter|
      flag = false if risk.include?(letter)
    }
    return flag
  end

  # "show_result"用のメソッド
  # "log"フォルダ内のフォルダ名を取得
  def dir_s_entries(path)

    ary = Dir.entries(path)
    ary.delete(".")
    ary.delete("..")
    dir = []

    ary.map{ |i|

      if File.directory?("#{path}/#{i}")
        dir << i
      end
    }
    return dir
  end

  def dir_rename(name, out)

    begin
      File.rename(name, out)
    rescue
      p "Error :: dir_rename"
    end
  end

  def get_absolute_path(filename)

    fso = WIN32OLE.new("Scripting.FileSystemObject")
    return fso.GetAbsolutePathName(filename)
  end

  def calc_float(time_f)

    time = (time_f * 100).to_i / 100.0 # 小数点第2位未満を切り捨て
    return time
  end
end


class Timer

  def set  # 時間を初期化
    @startTime = Time.now
  end

  def get  # 経過時間を得る
    return Time.now - @startTime
  end
end


if __FILE__ == $0

  include Common
  play_beep
end
