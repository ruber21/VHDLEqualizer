module audio(
  // Clock Input (50 MHz)
  input CLOCK_50, // 50 MHz
  input CLOCK_27, // 27 MHz
  //  Push Buttons
  input  [3:0]  KEY,
  //  DPDT Switches 
  input  [17:0]  SW,
  //  7-SEG Displays
  output  [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
  //  LEDs
  output  [8:0]  LEDG,  //  LED Green[8:0]
  output  [17:0]  LEDR, //  LED Red[17:0]
  // TV Decoder
  output TD_RESET, // TV Decoder Reset
  // I2C
  inout  I2C_SDAT, // I2C Data
  output I2C_SCLK, // I2C Clock
  // Audio CODEC
  output/*inout*/ AUD_ADCLRCK, // Audio CODEC ADC LR Clock
  input     AUD_ADCDAT,  // Audio CODEC ADC Data
  output /*inout*/  AUD_DACLRCK, // Audio CODEC DAC LR Clock
  output AUD_DACDAT,  // Audio CODEC DAC Data
  inout     AUD_BCLK,    // Audio CODEC Bit-Stream Clock
  output AUD_XCK,     // Audio CODEC Chip Clock
  //  GPIO Connections
  inout  [35:0]  GPIO_0, GPIO_1
);


//    All inout port turn to tri-state
assign    GPIO_0        =    36'hzzzzzzzzz;
assign    GPIO_1        =    36'hzzzzzzzzz;

wire [6:0] myclock;
wire RST;
assign RST = KEY[0];

// reset delay gives some time for peripherals to initialize
wire DLY_RST;
Reset_Delay r0(    .iCLK(CLOCK_50),.oRESET(DLY_RST) );

// Send switches to red leds 
assign LEDR = SW;

// Turn off green leds
assign LEDG = 0;

assign    TD_RESET = 1'b1;  // Enable 27 MHz

VGA_Audio_PLL     p1 (    
    .areset(~DLY_RST),
    .inclk0(CLOCK_27),
    .c0(VGA_CTRL_CLK),
    .c1(AUD_CTRL_CLK),
    .c2(VGA_CLK)
);

I2C_AV_Config u3(    
//    Host Side
  .iCLK(CLOCK_50),
  .iRST_N(KEY[0]),
//    I2C Side
  .I2C_SCLK(I2C_SCLK),
  .I2C_SDAT(I2C_SDAT)    
);

assign    AUD_ADCLRCK    =    AUD_DACLRCK;
assign    AUD_XCK        =    AUD_CTRL_CLK;

audio_clock u4(    
//    Audio Side
   .oAUD_BCK(AUD_BCLK),
   .oAUD_LRCK(AUD_DACLRCK),
//    Control Signals
  .iCLK_18_4(AUD_CTRL_CLK),
   .iRST_N(DLY_RST)    
);

wire [15:0] audio_inL, audio_inR;
reg [15:0] audio_outL,audio_outR;

always @(negedge AUD_DACLRCK)
    audio_outR <= audio_inR;

always @(posedge AUD_DACLRCK)
    audio_outL <= audio_inL;


audio_converter u5(
    // Audio side
    .AUD_BCK(AUD_BCLK),       // Audio bit clock
    .AUD_LRCK(AUD_DACLRCK), // left-right clock
    .AUD_ADCDAT(AUD_ADCDAT),
    .AUD_DATA(AUD_DACDAT),
    // Controller side
    .iRST_N(DLY_RST),  // reset
    .AUD_outL(audio_outL),
    .AUD_outR(audio_outR),
    .AUD_inL(audio_inL),
    .AUD_inR(audio_inR)
);


// send audio data to seven-segment displays

hex_7seg d7(audio_outL[15:12],HEX7);
hex_7seg d6(audio_outL[11:8],HEX6);
hex_7seg d5(audio_outL[7:4],HEX5);
hex_7seg d4(audio_outL[3:0],HEX4);
hex_7seg d3(audio_outR[15:12],HEX3);
hex_7seg d2(audio_outR[11:8],HEX2);
hex_7seg d1(audio_outR[7:4],HEX1);
hex_7seg d0(audio_outR[3:0],HEX0);

endmodule

//audio_clock.v            
                    
//audio_converter.v


//hex_7seg.v


//I2C_AV_Config.v


//I2C_Controller.v

//reset_delay.v


//VGA_Audio_PLL.v

