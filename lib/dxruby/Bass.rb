#!ruby -Ks
# Rubyからbass.dllを使うラッパ bass.rb ver 0.0.1
require 'Win32API'

module Bass
  # 構造体やポインタを扱うものは使い方に注意。
  # 定義が間違っている可能性もあるので使うときは確認すること。
  BASS_SetConfig = Win32API.new("bass", "BASS_SetConfig", "II", "I")
  BASS_GetConfig = Win32API.new("bass", "BASS_GetConfig", "I", "I")
  BASS_SetConfigPtr = Win32API.new("bass", "BASS_SetConfigPtr", "IP", "I")
  BASS_GetConfigPtr = Win32API.new("bass", "BASS_GetConfigPtr", "I", "P")
  BASS_GetVersion = Win32API.new("bass", "BASS_GetVersion", "", "I")
  BASS_ErrorGetCode = Win32API.new("bass", "BASS_ErrorGetCode", "", "I")
  BASS_GetDeviceInfo = Win32API.new("bass", "BASS_GetDeviceInfo", "IP", "I")
  BASS_Init = Win32API.new("bass", "BASS_Init", "IIIIP", "I")
  BASS_SetDevice = Win32API.new("bass", "BASS_SetDevice", "I", "I")
  BASS_GetDevice = Win32API.new("bass", "BASS_GetDevice", "", "I")
  BASS_Free = Win32API.new("bass", "BASS_Free", "", "I")
  BASS_GetDSoundObject = Win32API.new("bass", "BASS_GetDSoundObject", "I", "P")
  BASS_GetInfo = Win32API.new("bass", "BASS_GetInfo", "P", "I")
  BASS_Update = Win32API.new("bass", "BASS_Update", "I", "I")
  BASS_GetCPU = Win32API.new("bass", "BASS_GetCPU", "", "I")
  BASS_Start = Win32API.new("bass", "BASS_Start", "", "I")
  BASS_Stop = Win32API.new("bass", "BASS_Stop", "", "I")
  BASS_Pause = Win32API.new("bass", "BASS_Pause", "", "I")
  BASS_SetVolume = Win32API.new("bass", "BASS_SetVolume", "I", "I")
  BASS_GetVolume = Win32API.new("bass", "BASS_GetVolume", "", "I")
  BASS_PluginLoad = Win32API.new("bass", "BASS_PluginLoad", "PI", "I")
  BASS_PluginFree = Win32API.new("bass", "BASS_PluginFree", "I", "I")
  BASS_PluginGetInfo = Win32API.new("bass", "BASS_PluginGetInfo", "I", "P")
  BASS_Set3DFactors = Win32API.new("bass", "BASS_Set3DFactors", "III", "I")
  BASS_Get3DFactors = Win32API.new("bass", "BASS_Get3DFactors", "PPP", "I")
  BASS_Set3DPosition = Win32API.new("bass", "BASS_Set3DPosition", "PPPP", "I")
  BASS_Get3DPosition = Win32API.new("bass", "BASS_Get3DPosition", "PPPP", "I")
  BASS_Apply3D = Win32API.new("bass", "BASS_Apply3D", "", "I")
  BASS_SetEAXParameters = Win32API.new("bass", "BASS_SetEAXParameters", "IIII", "I")
  BASS_GetEAXParameters = Win32API.new("bass", "BASS_GetEAXParameters", "PPPP", "I")
  BASS_MusicLoad = Win32API.new("bass", "BASS_MusicLoad", "IPIIIII", "I")
  BASS_MusicFree = Win32API.new("bass", "BASS_MusicFree", "I", "I")
  BASS_SampleLoad = Win32API.new("bass", "BASS_SampleLoad", "IPIIIII", "I")
  BASS_SampleCreate = Win32API.new("bass", "BASS_SampleCreate", "IIIII", "I")
  BASS_SampleFree = Win32API.new("bass", "BASS_SampleFree", "I", "I")
  BASS_SampleSetData = Win32API.new("bass", "BASS_SampleSetData", "IP", "I")
  BASS_SampleGetData = Win32API.new("bass", "BASS_SampleGetData", "IP", "I")
  BASS_SampleGetInfo = Win32API.new("bass", "BASS_SampleGetInfo", "IP", "I")
  BASS_SampleSetInfo = Win32API.new("bass", "BASS_SampleSetInfo", "IP", "I")
  BASS_SampleGetChannel = Win32API.new("bass", "BASS_SampleGetChannel", "II", "I")
  BASS_SampleGetChannels = Win32API.new("bass", "BASS_SampleGetChannels", "IP", "I")
  BASS_SampleStop = Win32API.new("bass", "BASS_SampleStop", "I", "I")
  BASS_StreamCreate = Win32API.new("bass", "BASS_StreamCreate", "IIIPP", "I")
  BASS_StreamCreateFile = Win32API.new("bass", "BASS_StreamCreateFile", "IPIIIII", "I")
  BASS_StreamCreateURL = Win32API.new("bass", "BASS_StreamCreateURL", "PIIPP", "I")
  BASS_StreamCreateFileUser = Win32API.new("bass", "BASS_StreamCreateFileUser", "IIPP", "I")
  BASS_StreamFree = Win32API.new("bass", "BASS_StreamFree", "I", "I")
  BASS_StreamGetFilePosition = Win32API.new("bass", "BASS_StreamGetFilePosition", "II", "I")
  BASS_StreamPutData = Win32API.new("bass", "BASS_StreamPutData", "IPI", "I")
  BASS_StreamPutFileData = Win32API.new("bass", "BASS_StreamPutFileData", "IPI", "I")
  BASS_RecordGetDeviceInfo = Win32API.new("bass", "BASS_RecordGetDeviceInfo", "IP", "I")
  BASS_RecordInit = Win32API.new("bass", "BASS_RecordInit", "I", "I")
  BASS_RecordSetDevice = Win32API.new("bass", "BASS_RecordSetDevice", "I", "I")
  BASS_RecordGetDevice = Win32API.new("bass", "BASS_RecordGetDevice", "", "I")
  BASS_RecordFree = Win32API.new("bass", "BASS_RecordFree", "", "I")
  BASS_RecordGetInfo = Win32API.new("bass", "BASS_RecordGetInfo", "P", "I")
  BASS_RecordGetInputName = Win32API.new("bass", "BASS_RecordGetInputName", "I", "P")
  BASS_RecordSetInput = Win32API.new("bass", "BASS_RecordSetInput", "III", "I")
  BASS_RecordGetInput = Win32API.new("bass", "BASS_RecordGetInput", "IP", "I")
  BASS_RecordStart = Win32API.new("bass", "BASS_RecordStart", "IIIPP", "I")
  BASS_ChannelBytes2Seconds = Win32API.new("bass", "BASS_ChannelBytes2Seconds", "III", "I")
  BASS_ChannelSeconds2Bytes = Win32API.new("bass", "BASS_ChannelSeconds2Bytes", "II", "I")
  BASS_ChannelGetDevice = Win32API.new("bass", "BASS_ChannelGetDevice", "I", "I")
  BASS_ChannelSetDevice = Win32API.new("bass", "BASS_ChannelSetDevice", "II", "I")
  BASS_ChannelIsActive = Win32API.new("bass", "BASS_ChannelIsActive", "I", "I")
  BASS_ChannelGetInfo = Win32API.new("bass", "BASS_ChannelGetInfo", "IP", "I")
  BASS_ChannelGetTags = Win32API.new("bass", "BASS_ChannelGetTags", "II", "P")
  BASS_ChannelFlags = Win32API.new("bass", "BASS_ChannelFlags", "III", "I")
  BASS_ChannelUpdate = Win32API.new("bass", "BASS_ChannelUpdate", "II", "I")
  BASS_ChannelLock = Win32API.new("bass", "BASS_ChannelLock", "II", "I")
  BASS_ChannelPlay = Win32API.new("bass", "BASS_ChannelPlay", "II", "I")
  BASS_ChannelStop = Win32API.new("bass", "BASS_ChannelStop", "I", "I")
  BASS_ChannelPause = Win32API.new("bass", "BASS_ChannelPause", "I", "I")
  BASS_ChannelSetAttribute = Win32API.new("bass", "BASS_ChannelSetAttribute", "III", "I")
  BASS_ChannelGetAttribute = Win32API.new("bass", "BASS_ChannelGetAttribute", "IIP", "I")
  BASS_ChannelSlideAttribute = Win32API.new("bass", "BASS_ChannelSlideAttribute", "IIII", "I")
  BASS_ChannelIsSliding = Win32API.new("bass", "BASS_ChannelIsSliding", "II", "I")
  BASS_ChannelSet3DAttributes = Win32API.new("bass", "BASS_ChannelSet3DAttributes", "IIIIIII", "I")
  BASS_ChannelGet3DAttributes = Win32API.new("bass", "BASS_ChannelGet3DAttributes", "IPPPPPP", "I")
  BASS_ChannelSet3DPosition = Win32API.new("bass", "BASS_ChannelSet3DPosition", "IPPP", "I")
  BASS_ChannelGet3DPosition = Win32API.new("bass", "BASS_ChannelGet3DPosition", "IPPP", "I")
  BASS_ChannelGetLength = Win32API.new("bass", "BASS_ChannelGetLength", "II", "I")
  BASS_ChannelSetPosition = Win32API.new("bass", "BASS_ChannelSetPosition", "IIII", "I")
  BASS_ChannelGetPosition = Win32API.new("bass", "BASS_ChannelGetPosition", "II", "I")
  BASS_ChannelGetLevel = Win32API.new("bass", "BASS_ChannelGetLevel", "I", "I")
  BASS_ChannelGetData = Win32API.new("bass", "BASS_ChannelGetData", "IPI", "I")
  BASS_ChannelSetSync = Win32API.new("bass", "BASS_ChannelSetSync", "IIIIPP", "I")
  BASS_ChannelRemoveSync = Win32API.new("bass", "BASS_ChannelRemoveSync", "II", "I")
  BASS_ChannelSetDSP = Win32API.new("bass", "BASS_ChannelSetDSP", "IPPI", "I")
  BASS_ChannelRemoveDSP = Win32API.new("bass", "BASS_ChannelRemoveDSP", "II", "I")
  BASS_ChannelSetLink = Win32API.new("bass", "BASS_ChannelSetLink", "II", "I")
  BASS_ChannelRemoveLink = Win32API.new("bass", "BASS_ChannelRemoveLink", "II", "I")
  BASS_ChannelSetFX = Win32API.new("bass", "BASS_ChannelSetFX", "III", "I")
  BASS_ChannelRemoveFX = Win32API.new("bass", "BASS_ChannelRemoveFX", "II", "I")
  BASS_FXSetParameters = Win32API.new("bass", "BASS_FXSetParameters", "IP", "I")
  BASS_FXGetParameters = Win32API.new("bass", "BASS_FXGetParameters", "IP", "I")
  BASS_FXReset = Win32API.new("bass", "BASS_FXReset", "I", "I")

  # bass.dllのエラーコード
  Errmsg = {
    1=>"MEM",2=>"FILEOPEN",3=>"DRIVER",4=>"BUFLOST",5=>"HANDLE",6=>"FORMAT",7=>"POSITION",8=>"INIT",
    9=>"START",14=>"ALREADY",18=>"NOCHAN",19=>"ILLTYPE",20=>"ILLPARAM",21=>"NO3D",22=>"NOEAX",23=>"DEVICE",
    24=>"NOPLAY",25=>"FREQ",27=>"NOTFILE",29=>"NOHW",31=>"EMPTY",32=>"NONET",33=>"CREATE",34=>"NOFX",
    37=>"NOTAVAIL",38=>"DECODE",39=>"DX",40=>"TIMEOUT",41=>"FILEFORM",42=>"SPEAKER",43=>"VERSION",44=>"CODEC",
    45=>"ENDED",-1=>" UNKNOWN"
  }
  def self.err
    raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
  end

  # bass.dll初期化
  def self.init(hWnd, samplerate = 44100)
    if (BASS_GetVersion.call >> 16) != 0x0204 then
      raise("bass.dllバージョン2.4系以外には対応しておりません")
    end
    err if BASS_Init.call(-1, samplerate, 0, hWnd, nil) == 0
  end

  # bass.dll解放
  def self.free
    err if BASS_Free.call == 0
  end

  # sampleロード
  def self.loadSample(filename, max = 1)
    return Sample.new(filename, max)
  end

  # streamロード
  def self.loadStream(filename)
    return Stream.new(filename)
  end

  # sampleグローバルボリューム設定(0～10000整数)
  def self.sampleVolume=(vol)
    ::Bass.err if BASS_SetConfig.call(4, vol) == 0
  end

  # sampleグローバルボリューム取得(0～10000整数)
  def self.sampleVolume
    vol = BASS_GetConfig.call(4)
    ::Bass.err if vol == -1
    return vol
  end

  # streamグローバルボリューム設定(0～10000整数)
  def self.streamVolume=(vol)
    ::Bass.err if BASS_SetConfig.call(5, vol) == 0
  end

  # streamグローバルボリューム取得(0～10000整数)
  def self.streamVolume
    vol = BASS_GetConfig.call(5)
    ::Bass.err if vol == -1
    return vol
  end

#なんだかうまく動かないのでコメントにしとく
#  # Bassベースボリューム取得(0.0～1.0float)
#  def self.volume
#    vol = BASS_GetVolume.call
#    ::Bass.err if vol == -1
#    return [vol].pack("I").unpack("f")[0]
#  end

  # Sampleを表すクラス
  class Sample
    def initialize(filename, max = 1)
      @handle = BASS_SampleLoad.call(0, filename, 0, 0, 0, max, 0x20000)
      ::Bass.err if @handle == 0
    end

    # 解放
    def free
      ::Bass.err if BASS_SampleFree.call(@handle) == 0
    end

    # 再生
    def play(option = {})
      ch = BASS_SampleGetChannel.call(@handle, 0)
      ::Bass.err if ch == 0

      if option[:loop] then
        ::Bass.err if BASS_ChannelFlags.call(ch, 4, 4) == -1
      end
      if option[:pan] then
        ::Bass.err if BASS_ChannelSetAttribute.call(ch, 3, [option[:pan]].pack("f").unpack("I")[0]) == -1
      end
      if option[:volume] then
        ::Bass.err if BASS_ChannelSetAttribute.call(ch, 2, [option[:volume]].pack("f").unpack("I")[0]) == -1
      end
      if option[:fadevolume] and option[:fadetime] then
        ::Bass.err if BASS_ChannelSlideAttribute.call(ch, 2, [option[:fadevolume]].pack("f").unpack("I")[0], option[:fadetime]) == -1
      end

      ::Bass.err if BASS_ChannelPlay.call(ch, 0) == 0
      return ch
    end

    # 再生中のchのパン変更。-1.0(左)～1.0(右)。float型で。
    def setPan(ch, pan)
      ::Bass.err if BASS_ChannelSetAttribute.call(ch, 3, [pan].pack("f").unpack("I")[0]) == -1
    end

    # 再生中のchのボリューム変更。0～1まで、float型で。
    def setVolume(ch, v)
      ::Bass.err if BASS_ChannelSetAttribute.call(ch, 2, [v].pack("f").unpack("I")[0]) == -1
    end

    # 再生中のchのフェード設定。vは0～1まで、float型で。tはミリ秒。
    def setFade(ch, v, t)
      ::Bass.err if BASS_ChannelSlideAttribute.call(ch, 2, [v].pack("f").unpack("I")[0], t) == -1
    end

    # ch停止
    def stop(ch = nil)
      if ch == nil then
        ::Bass.err if BASS_SampleStop.call(@handle) == 0
      else
        ::Bass.err if BASS_ChannelStop.call(ch) == 0
      end
    end
  end

  # Streamを表すクラス
  class Stream
    def initialize(filename)
      @ch = BASS_StreamCreateFile.call(0, filename, 0, 0, 0, 0, 0)
      ::Bass.err if @ch == 0
    end

    # 解放
    def free
      ::Bass.err if BASS_StreamFree.call(@ch) == 0
    end

    # 再生
    def play(option = {})
      if option[:loop] then
        ::Bass.err if BASS_ChannelFlags.call(@ch, 4, 4) == -1
      end
      if option[:pan] then
        ::Bass.err if BASS_ChannelSetAttribute.call(@ch, 3, [option[:pan]].pack("f").unpack("I")[0]) == -1
      end
      if option[:volume] then
        ::Bass.err if BASS_ChannelSetAttribute.call(@ch, 2, [option[:volume]].pack("f").unpack("I")[0]) == -1
      end
      if option[:fadevolume] and option[:fadetime] then
        ::Bass.err if BASS_ChannelSlideAttribute.call(@ch, 2, [fadevolume].pack("f").unpack("I")[0], fadetime) == -1
      end
      ::Bass.err if BASS_ChannelPlay.call(@ch, 0) == 0
    end


    # パン変更。-1.0(左)～1.0(右)。float型で。
    def pan=(pan)
      ::Bass.err if BASS_ChannelSetAttribute.call(@ch, 3, [pan].pack("f").unpack("I")[0]) == -1
    end

    # ボリューム変更。0.0～1.0まで、float型で。
    def volume=(v)
      ::Bass.err if BASS_ChannelSetAttribute.call(@ch, 2, [v].pack("f").unpack("I")[0]) == -1
    end

    # 再生中のchのフェード設定。vは0～1まで、float型で。tはミリ秒。
    def setFade(v, t)
      ::Bass.err if BASS_ChannelSlideAttribute.call(@ch, 2, [v].pack("f").unpack("I")[0], t) == 0
    end

    # 停止
    def stop
      ::Bass.err if BASS_ChannelStop.call(@ch) == 0
    end
  end
end


if __FILE__ == $0

=begin
  #Stream再生とパン変更のサンプル
  require "dxruby"
  Bass.init(Window.hWnd)
  s = Bass.loadStream("test.ogg")
  s.play(:loop=>true)
  pan = 0.0

  Window.loop do
    pan += Input.x * 0.02
    pan = -1.0 if pan < -1.0
    pan = 1.0 if pan > 1.0
    s.pan=pan

    s.setFade(0, 1000) if Input.keyPush?(K_Z)
    s.setFade(1, 1000) if Input.keyPush?(K_C)

    break if Input.keyPush?(K_ESCAPE)
  end
  s.free
  Bass.free
=end

  #Sample再生のサンプル
  #Sampleはデータを全てメモリ内に読み込んでデコードします。
  #BGMにMP3やOGGを使う場合は、Streamをオススメします。
  #Sampleはplayするとチャンネル番号が返ってきて、
  #その番号を使って再生中の音のパンや音量を変更することができます。
  #StremもSampleも、playの引数に:loop=>trueを指定するとループします。
  #:panでパン設定、:volumeで音量設定もできます。
  #:fadevolumeでフェード目標音量、:fadetimeでフェード時間の設定ができます。
  require "dxruby"
  Bass.init(Window.hWnd)
  s = Bass.loadSample("test2.wav")
  ch = s.play(:loop=>true, :volume=>1.0)
  pan = 0

  Window.loop do
    pan += Input.x * 0.02
    pan = -1.0 if pan < -1.0
    pan = 1.0 if pan > 1.0
    s.setPan(ch, pan)

    s.setFade(ch, 0, 1000) if Input.keyPush?(K_Z)
    s.setFade(ch, 1, 1000) if Input.keyPush?(K_C)

    break if Input.keyPush?(K_ESCAPE)
  end

  s.free
  Bass.free
end

#各種bassの機能については今後、気が向いたときに追加していきます。
