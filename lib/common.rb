#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE= "s"
require "jcode"

# common.rb Ver 1.2
# Ruby�ėp���C�u����

require "Win32API"
require "win32ole"


module Common

  # �X���b�h��~����
  def kill_thread (t_name) # ���� - �X���b�h�E�I�u�W�F�N�g
    Thread.kill(t_name)
  end

  # �����_�������l�����imin��max�j
  def rand_float(min, max) # ���� - Int�^�̍ŏ��l�ƍő�l
    return rand() * (max - min) + min
  end

  # �͈͓��̃����_���Ȑ����𐶐�
  def random_int(min, max)
    return rand(max - min) + min
  end

  # �z��̗v�f�̏d���̂��邷�ׂĂ̏����t���g�ݍ��킹��Ԃ�
  def all_rep_permu(array) # ���� - �z��
    all_rep_permu = []
    array.count.times{|i| all_rep_permu += array.repeated_permutation(i + 1).to_a.collect{|a| a.join}}
    return all_rep_permu
  end

  # 0����div�����Ƃ��Ď����I�ɐ������݂̕�����Ԃ��֐��i���E�����֐��j
  def gen_sign(cnt, div) # ���� -> cnt�͘A���J�E���g�Cdiv�͋��E�l
    count = (div - 2).div(4) - cnt # �����̏C��
    y = Math.sin(Math::PI / (div - 1) * count + Math::PI / 4) # �ʑ�
    return y <=> 0 # ������Ԃ��֐��isign�j
  end

  # �ꎟ���z��V���b�t���̍ŋ��A���S���Y���i"�t�B�b�V���[�E���b�e"�̃A���S���Y���j
  def fisher_yates(items) # ���� - �z��
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
      @beep.call(304, 250) # beep�֐��̌Ăяo���B304�͎��g���A250�͉��̒����B
    rescue
      @beep = Win32API.new("kernel32", "Beep", %w(l l), 'l')
      retry
    end
  end

  # �t�@�C�����Ɏg���Ȃ������񂪊܂܂�Ă��Ȃ����`�F�b�N
  def check_input_box(name)

    strings = name.split(//)

    risk = ["\\", "/", ":", "*", "?", '"', "<", ">", "|"]
    flag = true

    strings.map{ |letter|
      flag = false if risk.include?(letter)
    }
    return flag
  end

  # "show_result"�p�̃��\�b�h
  # "log"�t�H���_���̃t�H���_�����擾
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

    time = (time_f * 100).to_i / 100.0 # �����_��2�ʖ�����؂�̂�
    return time
  end
end


class Timer

  def set  # ���Ԃ�������
    @startTime = Time.now
  end

  def get  # �o�ߎ��Ԃ𓾂�
    return Time.now - @startTime
  end
end


if __FILE__ == $0

  include Common
  play_beep
end
