#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE= "s"
require "jcode"

# Created by Toshiharu Tadano 2015-2019.
# This class needs require wav-file.rb.


class WavAnalyze

  def initialize
    @waves = nil # ruby -Ks
    @max = nil # 最大値
    @min = nil # 最小値
    @num = nil # データ数
    
    @moving_average_waves # 移動平均データ
    @start = nil # 開始点
    @end = nil # 終了点
    @start_time = nil
    @end_time = nil
  end
  
  attr_reader :waves, :max, :min, :num, :start, :end, :moving_average_waves, :threshold, :start_time, :end_time

  # WAVファイルの読み込み
  def load_wave(filename, skip)

    f = File.open(filename, "rb")
    format, chunks = WavFile::readAll(f)
    f.close
    data_chunk = nil

    chunks.each{|c|
      data_chunk = c if c.name == "data"
    }

    if data_chunk == nil
      puts "no data chunk"
      exit 1
    end

    bit = 's*' if format.bitPerSample == 16 # int16_t
    bit = 'c*' if format.bitPerSample == 8 # signed char
    wavs = data_chunk.data.unpack(bit) # 16bit or 8bitずつbinaryから読み出し

    out_waves = []

    # skipだけ飛ばして処理
    (wavs.size / skip).times do |i|
      out_waves[i] = wavs[i*skip]
    end
  
    @format = format
    @waves = out_waves
    @max = out_waves.max
    @min = out_waves.min
    @amplitude = @max - @min
    # @threshold = @amplitude/2*0.05 # 閾値設定　一応振幅の10分の1 -- 大きな間違いなのね！
    @num = out_waves.size
  end


  # 移動平均処理
  def moving_average(range = 100)

    outs = []
    total = 0

    @waves.size.times do |i|
      total -= @waves[i - range].abs if i > range
      total += @waves[i + range].abs if i + range < @waves.size
      outs.push((total / (range * 2).round))
    end

    @moving_average_waves = outs
    return outs
  end

  # 閾値検出 -- 手直ししました
  def detect_threshold(waves)

    waves_abs = waves.map{|foctor| foctor.abs}
    @threshold = waves_abs.max * 0.1 # 閾値設定 振幅の10分の1
  end
  
  # 波形の立ち上がりを検出
  def detect_start_point(waves)

    waves.each_with_index do |e, index|

      # 閾値を超えたらブレイク
      if e.abs >= @threshold
        @start = index
        break
      end
    end

    self.calc_start_time(@start)
    return @start
  end
  
  def calc_start_time(start_point)

    @start_time = start_point.to_f / (@format.hz * @format.channel)
    @start_time = (@start_time * 1000).round / 1000.0   # 小数点以下3桁で四捨五入
  end
  
  # 波形の終わりを検出
  def detect_end_point(waves)

    @num.times do |i|

      # 閾値を超えたらブレイク
      if waves[@num - 1 - i].abs >= @threshold
        @end = @num - 1 - i
        break
      end
    end

    self.calc_end_time(@end)
    return @end
  end
  
  def calc_end_time(end_point)

    @end_time = end_point.to_f / (@format.hz * @format.channel)
    @end_time = (@end_time * 1000).round / 1000.0  # 小数点以下3桁で四捨五入
  end
  
  def time
    return @end_time - @start_time
  end
  
  # 分析する
  def analyze(filename, skip = 1)

    self.load_wave(filename, skip)
    moving_average_wavs = self.moving_average(100) # -- 引数が移動平均の精度（小さいほどタイミングのずれがなくなる）

    self.detect_threshold(moving_average_wavs)  # 閾値設定 移動平均の振幅の10分の1
    self.detect_start_point(moving_average_wavs)
    self.detect_end_point(moving_average_wavs)
  end
end
