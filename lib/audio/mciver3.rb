#
#  mci.rb
#  以下のプログラムに録音機能の拡張
#  mciplay.rb(http://www.osk.3web.ne.jp/~nyasu/software/ruby.html#mciplay)
#
#  ■ver2
#  チャンネル数,サンプリングレート,bit per sampleを設定可能に
#  やはりvistaや７では動かない・・・
#
#  ■ver3
#  vistaや７で動作するように改良
#  全ての音質パラメータを一気に設定しなければならないらしい
#  それにともなって bytespersec と alignment の設定も行う必要があるので
#  wavファイルの訂正(correct)が不要になった。

#  mciplay.rb
#  Programmed by nyasu <nyasu@osk.3web.ne.jp>
#  2000/02/24
#
#  samples are at bottom of this file
#

require 'Win32API'


class MCIError < RuntimeError; end

# for closing devices
$mciOpenedDeviceAliases=Array.new

at_exit do

  $mciOpenedDeviceAliases.each do |v|
#    print "closing mci devices(alias): #{v}\n"
    MCIFilePlayer.MCISendString "close "+v
  end
end

class MCIPlayer
  MCISendString = Win32API.new "winmm","mciSendString",["P","I","I","I"],"I"
  MCISendString2 = Win32API.new "winmm","mciSendString",["P","P","I","I"],"I"
  MCIGetErrorString = Win32API.new "winmm","mciGetErrorString",["I","P","I"],"I"
  SystemSleep = Win32API.new "kernel32","Sleep",["I"],"I"
  Getlasterror = Win32API.new "kernel32", "GetLastError", "v", "i"

  
  def initialize(aliasname="rubymci",notify=nil) #notify as hWnd
    @aliasname = aliasname
    @notifywin = if notify then notify.to_i else 0 end
  end

  def renew(aliasname=nil, notify=nil) #notify as hWnd
    close if @open_flag
    if aliasname then
      @aliasname = aliasname 
    else
      @aliasname = @aliasname.succ
    end
    @notifywin = if notify then notify.to_i else 0 end
    self
  end

  def ready?
    @tmpready="          "
    sendstring "status #{@aliasname} ready",@tmpready
    return (@tmpready[0,4].upcase == "TRUE")
  end
  
  def wait4ready
    until ready? do
      SystemSleep(50)
    end
  end

  def rerror
    errstr_buffer=" "*129
   # puts @errno
    MCIGetErrorString.call(@errno,errstr_buffer,128)
    #puts MCIError
    raise MCIError,errstr_buffer
    false
  end

  def sendstring(cmdstr,argstr=nil)
    unless argstr then
      @errno = MCISendString.call cmdstr,0,0,@notifywin
    else
      @errno = MCISendString2.call cmdstr,argstr,argstr.length,@notifywin
    end
    
    #puts "Getlasterror:#{Getlasterror.call()}"
    #puts "errno:#{@errno}"
    rerror if @errno>0
    #self
  end

  def opened?
    @open_flag
  end

  def mode
    errstr_buffer=" "*129
    @errno = MCISendString2.call "status "+@aliasname+" mode",
                                  errstr_buffer,128,@notifywin
    errstr_buffer
  end

  def open(cmdstr)
    sendstring "open " + cmdstr + " alias " + @aliasname
    $mciOpenedDeviceAliases |= [@aliasname]
    @open_flag=true
    self
  end

  def play(opt="")
    wait4ready
    sendstring "play "+@aliasname + " #{opt}"
  end

  def pause(opt="")
    wait4ready
    sendstring "pause "+@aliasname + " #{opt}"
  end

  def stop(opt="")
    wait4ready
    sendstring "stop "+@aliasname + " #{opt}"
  end

  def close(opt="")
    wait4ready
    sendstring "close "+@aliasname + " #{opt}"
    $mciOpenedDeviceAliases.delete @aliasname
    @open_flag=false
    self
  end

  def seek(pointstr,opt="")
    wait4ready
    sendstring "seek "+@aliasname+" "+pointstr + " #{opt}"
  end
  
  def rewind
    seek "to start"
  end
  def seek2end
    seek "to end"
  end
  def seek2pos(n)
    seek "to "+n.to_s
  end

end


#WAV録音  ステレオ 16 bit、サンプリング周波数 44.1 kHz でしたいけどできない・・・
class MCIRecorder < MCIPlayer
  
  def initialize(aliasname="rubymcicd",notify=nil)  #notify as hWnd
    super
    @channels = 1 #チャンネル 1 or 2
    @bitspersample = 16    #bit  8 or 16
    @samplespersec = 16000 #44100    #サンプリング周波数 44.1 kHz
  end
  
  attr_accessor :channels, :bitspersample, :samplespersec
  
  def open(opt="")
    @filename = nil
    format = check_format
    sendstring "open new alias " + @aliasname + " type waveaudio"
    if format != :default
      commandString =  "set " + @aliasname + " channels #{@channels} "
      commandString += "samplespersec #{@samplespersec} "
      commandString += "bytespersec #{(@bitspersample * @channels * @samplespersec) / 8} "
      commandString += "alignment #{@channels * (@bitspersample/8)} "
      commandString += "bitspersample #{@bitspersample}"
      
      sendstring commandString
      
      #sendstring "set " + @aliasname + " channels #{@channels}"   #チャンネル
      #puts ""
      #sendstring "set " + @aliasname + " bitspersample #{@bitspersample}"  #オーディオサンプルサイズ
      #sendstring "set " + @aliasname + " samplespersec #{@samplespersec}"   #サンプリング周波数
    end
    $mciOpenedDeviceAliases |= [@aliasname]
    @open_flag=true
    self
  end
  
  #フォーマットチェック
  def check_format
    if @channels != 1 and @channels != 2
      puts "チャンネル数が1か2ではありません"
      exit
    end
    if @bitspersample != 8 and @bitspersample != 16
      puts "bitspersampleが8か16ではありません"
      exit
    end
    #デフォルト設定なら
    if @channels == 1 and @bitspersample == 8 and @samplespersec == 11025
      return :default
    else
    end
  end
  
  def record(opt="")
    wait4ready
    sendstring "record "+@aliasname + " #{opt}"
  end
  
  def save(opt="")
    @filename = opt
    wait4ready
    sendstring "save "+@aliasname + " #{opt}"
    #correct_file(opt)
  end
  
  #ver2以降は不要
  #mciのおかしな部分、wavファイルフォーマット情報の書き出しで間違った値を出力を直す
  def correct_file(filename)
    f = File.open(filename, "rb")
    format, chunks = WavFile::readAll(f)
    f.close
    format.bytePerSec = @samplespersec * @channels * (@bitspersample/8) #訂正
    out = File.open(filename, "wb")
    WavFile::write(out, format, chunks)
    out.close
  end
  
  #ver2以降は不要
  #correct_fileと同じ引数にファイル名を使わない
  def correct
    #デフォルトの設定だったら処理しない
    if check_format == :default
      return
    end
    if @filename == nil
      puts "ファイル名がありません"
    end
    f = File.open(@filename, "rb")
    format, chunks = WavFile::readAll(f)
    f.close
    format.bytePerSec = @samplespersec * @channels * (@bitspersample/8) #訂正
    format.blockSize = @channels * (@bitspersample/8)#訂正
    out = File.open(@filename, "wb")
    WavFile::write(out, format, chunks)
    out.close
  end

end



#
class MCICDPlayer < MCIPlayer
  def initialize(aliasname="rubymcicd",notify=nil)  #notify as hWnd
    super
  end
  def open(opt="")
    super "cdaudio "+opt
  end
end

#
class MCIFilePlayer < MCIPlayer
  def initialize(filename=nil,aliasname="rubymcifile",notify=nil) #notify as hWnd
    @filename = filename
    super aliasname,notify
  end

  def renew(filename=nil, aliasname=nil, notify=nil) #notify as hWnd
    super aliasname,notify
    @filename = filename
    self
  end

  def open
    unless @filename then
      raise RuntimeError,"Filename not specified yet"
      return nil
    end

    super @filename
  end

  def setwindow_orig(hwnd)
    wait4ready
    sendstring "window "+@aliasname+" handle "+hwnd.to_s
  end

  def setwindow(win)          # win as SWin::Window
    setwindow_orig win.hWnd
  end

end


#######ライブラリのデバック################


#実行ファイルがこのファイルと一致すれば
if __FILE__ == $0

=begin sample : simple play(sync)
  m = MCIFilePlayer.new 'bell15a.wav'
  m.open
  m.play "wait"
  m.close
=end

#なぜか動かない．
=begin sample : repeat playing and wait 10sec.
  m = MCIFilePlayer.new "bell15a.wav"
  m.open
  m.play "repeat"     #←このオプション使えない？
  sleep 10
  m.close
=end


=begin sample : play-pause-play(sync)
  m = MCIFilePlayer.new "filecopy.avi","test"
  m.open
  m.play
  sleep 1;  m.pause;  sleep 2
  m.play "wait"
  m.close
=end

=begin sample : play cd-disk
  m = MCICDPlayer.new
  m.open.play; sleep 5
  m.stop
  m.seek "to 3"
  m.play; sleep 5
  m.stop
  m.close
=end



#録音処理のデバッグ
#=begin 
  require 'WavFile.rb'
  file = "rec_3_11025_b.wav"
  m = MCIRecorder.new   #インスタンス作成
  #m.channels = 1
  #m.bitspersample = 16    #bit  8 or 16
  m.samplespersec = 11025    #サンプリング周波数 44.1 kHz  
  
  #録音開始.２行でセット
  m.open
  m.record

  #5秒待って
  sleep(5)

  #録音終了.3行でセット
  m.stop
  m.save(file)
  m.close
  #m.correct


  #fomatを確認する
  format, chunks = WavFile::readAll open(file)
  puts format.to_s


#=end

end
