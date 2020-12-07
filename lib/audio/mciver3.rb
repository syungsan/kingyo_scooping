#
#  mci.rb
#  �ȉ��̃v���O�����ɘ^���@�\�̊g��
#  mciplay.rb(http://www.osk.3web.ne.jp/~nyasu/software/ruby.html#mciplay)
#
#  ��ver2
#  �`�����l����,�T���v�����O���[�g,bit per sample��ݒ�\��
#  ��͂�vista��V�ł͓����Ȃ��E�E�E
#
#  ��ver3
#  vista��V�œ��삷��悤�ɉ���
#  �S�Ẳ����p�����[�^����C�ɐݒ肵�Ȃ���΂Ȃ�Ȃ��炵��
#  ����ɂƂ��Ȃ��� bytespersec �� alignment �̐ݒ���s���K�v������̂�
#  wav�t�@�C���̒���(correct)���s�v�ɂȂ����B

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


#WAV�^��  �X�e���I 16 bit�A�T���v�����O���g�� 44.1 kHz �ł��������ǂł��Ȃ��E�E�E
class MCIRecorder < MCIPlayer
  
  def initialize(aliasname="rubymcicd",notify=nil)  #notify as hWnd
    super
    @channels = 1 #�`�����l�� 1 or 2
    @bitspersample = 16    #bit  8 or 16
    @samplespersec = 16000 #44100    #�T���v�����O���g�� 44.1 kHz
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
      
      #sendstring "set " + @aliasname + " channels #{@channels}"   #�`�����l��
      #puts ""
      #sendstring "set " + @aliasname + " bitspersample #{@bitspersample}"  #�I�[�f�B�I�T���v���T�C�Y
      #sendstring "set " + @aliasname + " samplespersec #{@samplespersec}"   #�T���v�����O���g��
    end
    $mciOpenedDeviceAliases |= [@aliasname]
    @open_flag=true
    self
  end
  
  #�t�H�[�}�b�g�`�F�b�N
  def check_format
    if @channels != 1 and @channels != 2
      puts "�`�����l������1��2�ł͂���܂���"
      exit
    end
    if @bitspersample != 8 and @bitspersample != 16
      puts "bitspersample��8��16�ł͂���܂���"
      exit
    end
    #�f�t�H���g�ݒ�Ȃ�
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
  
  #ver2�ȍ~�͕s�v
  #mci�̂������ȕ����Awav�t�@�C���t�H�[�}�b�g���̏����o���ŊԈ�����l���o�͂𒼂�
  def correct_file(filename)
    f = File.open(filename, "rb")
    format, chunks = WavFile::readAll(f)
    f.close
    format.bytePerSec = @samplespersec * @channels * (@bitspersample/8) #����
    out = File.open(filename, "wb")
    WavFile::write(out, format, chunks)
    out.close
  end
  
  #ver2�ȍ~�͕s�v
  #correct_file�Ɠ��������Ƀt�@�C�������g��Ȃ�
  def correct
    #�f�t�H���g�̐ݒ肾�����珈�����Ȃ�
    if check_format == :default
      return
    end
    if @filename == nil
      puts "�t�@�C����������܂���"
    end
    f = File.open(@filename, "rb")
    format, chunks = WavFile::readAll(f)
    f.close
    format.bytePerSec = @samplespersec * @channels * (@bitspersample/8) #����
    format.blockSize = @channels * (@bitspersample/8)#����
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


#######���C�u�����̃f�o�b�N################


#���s�t�@�C�������̃t�@�C���ƈ�v�����
if __FILE__ == $0

=begin sample : simple play(sync)
  m = MCIFilePlayer.new 'bell15a.wav'
  m.open
  m.play "wait"
  m.close
=end

#�Ȃ��������Ȃ��D
=begin sample : repeat playing and wait 10sec.
  m = MCIFilePlayer.new "bell15a.wav"
  m.open
  m.play "repeat"     #�����̃I�v�V�����g���Ȃ��H
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



#�^�������̃f�o�b�O
#=begin 
  require 'WavFile.rb'
  file = "rec_3_11025_b.wav"
  m = MCIRecorder.new   #�C���X�^���X�쐬
  #m.channels = 1
  #m.bitspersample = 16    #bit  8 or 16
  m.samplespersec = 11025    #�T���v�����O���g�� 44.1 kHz  
  
  #�^���J�n.�Q�s�ŃZ�b�g
  m.open
  m.record

  #5�b�҂���
  sleep(5)

  #�^���I��.3�s�ŃZ�b�g
  m.stop
  m.save(file)
  m.close
  #m.correct


  #fomat���m�F����
  format, chunks = WavFile::readAll open(file)
  puts format.to_s


#=end

end
