#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE= "s"
require "jcode"

# Created by Toshiharu Tadano 2015-2019.
# This class needs require wav-file.rb.


class WavAnalyze

  def initialize
    @waves = nil # ruby -Ks
    @max = nil # �ő�l
    @min = nil # �ŏ��l
    @num = nil # �f�[�^��
    
    @moving_average_waves # �ړ����σf�[�^
    @start = nil # �J�n�_
    @end = nil # �I���_
    @start_time = nil
    @end_time = nil
  end
  
  attr_reader :waves, :max, :min, :num, :start, :end, :moving_average_waves, :threshold, :start_time, :end_time

  # WAV�t�@�C���̓ǂݍ���
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
    wavs = data_chunk.data.unpack(bit) # 16bit or 8bit����binary����ǂݏo��

    out_waves = []

    # skip������΂��ď���
    (wavs.size / skip).times do |i|
      out_waves[i] = wavs[i*skip]
    end
  
    @format = format
    @waves = out_waves
    @max = out_waves.max
    @min = out_waves.min
    @amplitude = @max - @min
    # @threshold = @amplitude/2*0.05 # 臒l�ݒ�@�ꉞ�U����10����1 -- �傫�ȊԈႢ�Ȃ̂ˁI
    @num = out_waves.size
  end


  # �ړ����Ϗ���
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

  # 臒l���o -- �蒼�����܂���
  def detect_threshold(waves)

    waves_abs = waves.map{|foctor| foctor.abs}
    @threshold = waves_abs.max * 0.1 # 臒l�ݒ� �U����10����1
  end
  
  # �g�`�̗����オ������o
  def detect_start_point(waves)

    waves.each_with_index do |e, index|

      # 臒l�𒴂�����u���C�N
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
    @start_time = (@start_time * 1000).round / 1000.0   # �����_�ȉ�3���Ŏl�̌ܓ�
  end
  
  # �g�`�̏I�������o
  def detect_end_point(waves)

    @num.times do |i|

      # 臒l�𒴂�����u���C�N
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
    @end_time = (@end_time * 1000).round / 1000.0  # �����_�ȉ�3���Ŏl�̌ܓ�
  end
  
  def time
    return @end_time - @start_time
  end
  
  # ���͂���
  def analyze(filename, skip = 1)

    self.load_wave(filename, skip)
    moving_average_wavs = self.moving_average(100) # -- �������ړ����ς̐��x�i�������قǃ^�C�~���O�̂��ꂪ�Ȃ��Ȃ�j

    self.detect_threshold(moving_average_wavs)  # 臒l�ݒ� �ړ����ς̐U����10����1
    self.detect_start_point(moving_average_wavs)
    self.detect_end_point(moving_average_wavs)
  end
end
