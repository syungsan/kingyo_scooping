class SampleMappingShader < DXRuby::Shader
  hlsl = <<EOS
  float g_start;
  float g_level;
  texture tex0;
  sampler Samp = sampler_state
  {
   Texture =<tex0>;
   AddressU = BORDER;
   AddressV = BORDER;
  };

  float4 PS(float2 input : TEXCOORD0) : COLOR0
  {
    float4 output;
    float distance = radians(distance(input, float2(0.5, 0.5)) * 360 * 4 - g_start);
    float height = sin(distance);
    float slope = cos(distance);
    float d = clamp(-1,1,dot(normalize(float3(input.y - 0.5, input.x - 0.5,0 )), float3(0.5,-0.5,0.5)))*slope+1;
    input.y = input.y + height * g_level;

    output = tex2D( Samp, input ) * d;

    return output;
  }

  technique Raster
  {
   pass P0
   {
    PixelShader = compile ps_2_0 PS();
   }
  }
EOS

  @@core = DXRuby::Shader::Core.new(
      hlsl,
      {
          :g_start => :float,
          :g_level => :float,
      }
  )

  def initialize(speed=3, level=0.15)
    super(@@core, "Raster")
    self.g_start = 0.0
    self.g_level = 0.0
    @speed = speed
    @level = level
  end

  def update
    self.g_start += @speed
    self.g_level = @level
  end
end
