#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

require "rubygems"
require "win32/open3" # gem install win32-open3


class EyeMoTMouse

  attr_reader :mode

  if __FILE__ == $0 then
    COMMAND = "../EyeMoTMouse/EyeMoTMouse.exe"
  else
    COMMAND = "./EyeMoTMouse/EyeMoTMouse.exe"
  end

  def initialize()
    @stdin = nil
    @mode = :off
  end

  def open

    begin
      Thread.new do
        Open3.popen3(COMMAND) do |stdin, stdout, stderr, wait_thr|
          @stdin = stdin

          stdout.each do |line|
            puts line.chomp
          end
          # stderr.each do |line| line end
          # pid = wait_thr.value
        end
      end
      @mode = :on
    rescue
    end
  end

  def eye_off
    begin
      @stdin.write("mouse_off\n")
      @mode = :off
    rescue
    end
  end

  def eye_on
    begin
      @stdin.write("mouse_on\n")
      @mode = :on
    rescue
    end
  end

  def close
    begin
      @stdin.write("exit\n")
      @mode = :close
      sleep(0.5)
    rescue
    end
  end
end


if __FILE__ == $0 then

  eyemot_mouse = EyeMoTMouse.new
  eyemot_mouse.open
  p eyemot_mouse.stdin
end
