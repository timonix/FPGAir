`ifndef VERILATOR
module testbench;
  reg [4095:0] vcdfile;
  reg clock;
`else
module testbench(input clock, output reg genclock);
  initial genclock = 1;
`endif
  reg genclock = 1;
  reg [31:0] cycle = 0;
  reg [0:0] PI_rst;
  reg [17:0] PI_input_B_X;
  reg [17:0] PI_input_C_Z;
  reg [17:0] PI_input_C_X;
  reg [17:0] PI_input_B_Y;
  reg [17:0] PI_input_A_Z;
  reg [17:0] PI_input_A_X;
  reg [0:0] PI_run;
  wire [0:0] PI_clk = clock;
  reg [17:0] PI_input_B_Z;
  reg [4:0] PI_instruction_start_pointer;
  reg [17:0] PI_input_A_Y;
  reg [17:0] PI_input_C_Y;
  uCore UUT (
    .rst(PI_rst),
    .input_B_X(PI_input_B_X),
    .input_C_Z(PI_input_C_Z),
    .input_C_X(PI_input_C_X),
    .input_B_Y(PI_input_B_Y),
    .input_A_Z(PI_input_A_Z),
    .input_A_X(PI_input_A_X),
    .run(PI_run),
    .clk(PI_clk),
    .input_B_Z(PI_input_B_Z),
    .instruction_start_pointer(PI_instruction_start_pointer),
    .input_A_Y(PI_input_A_Y),
    .input_C_Y(PI_input_C_Y)
  );
`ifndef VERILATOR
  initial begin
    if ($value$plusargs("vcd=%s", vcdfile)) begin
      $dumpfile(vcdfile);
      $dumpvars(0, testbench);
    end
    #5 clock = 0;
    while (genclock) begin
      #5 clock = 0;
      #5 clock = 1;
    end
  end
`endif
  initial begin
`ifndef VERILATOR
    #1;
`endif
    // UUT.$auto$ghdl.\cc:806:import_module$261  = 18'b000000000000000001;
    UUT.a_regs = 54'b100000000000000000000000000000000010000000000000000001;
    UUT.b_regs = 54'b000100000000000000010000100000000000000000000000001000;
    UUT.c_regs = 54'b000000000000010000010000000000000000000000000000000001;
    UUT.instruction_pointer = 5'b00000;
    UUT.output_regs = 54'b000000000000000000000000000000000000000000000000000000;
    UUT.result_regs = 54'b111101111111111100000000000000000000000000000000000000;
    UUT.s_done = 1'b0;
    UUT.s_ready = 1'b1;
    UUT.\/1728 [5'b11111] = 17'b00000000000000000;
    UUT.\/1728 [5'b10000] = 17'b00000000000000000;
    UUT.\/1728 [5'b01111] = 17'b00000000000000000;
    UUT.\/1728 [5'b01110] = 17'b00000000000000000;
    UUT.\/1728 [5'b01101] = 17'b00000000000000000;
    UUT.\/1728 [5'b01100] = 17'b00000000000000000;
    UUT.\/1728 [5'b01011] = 17'b00000000000000000;
    UUT.\/1728 [5'b01010] = 17'b00000000000000000;
    UUT.\/1728 [5'b01001] = 17'b00000000000000000;
    UUT.\/1728 [5'b01000] = 17'b00000000000000000;
    UUT.\/1728 [5'b00111] = 17'b00000000000000000;
    UUT.\/1728 [5'b00110] = 17'b00000000000000000;
    UUT.\/1728 [5'b00101] = 17'b00000000000000000;
    UUT.\/1728 [5'b00100] = 17'b00000000000000000;
    UUT.\/1728 [5'b00011] = 17'b00000000000000000;
    UUT.\/1728 [5'b00010] = 17'b00000000000000000;

    // state 0
    PI_rst = 1'b0;
    PI_input_B_X = 18'b100000000000000001;
    PI_input_C_Z = 18'b100000000000000001;
    PI_input_C_X = 18'b100000000000000001;
    PI_input_B_Y = 18'b100000000000000001;
    PI_input_A_Z = 18'b100000000000000001;
    PI_input_A_X = 18'b100000000000000001;
    PI_run = 1'b1;
    PI_input_B_Z = 18'b100000000000000001;
    PI_instruction_start_pointer = 5'b01111;
    PI_input_A_Y = 18'b100000000000000001;
    PI_input_C_Y = 18'b100000000000000001;
  end
  always @(posedge clock) begin
    // state 1
    if (cycle == 0) begin
      PI_rst <= 1'b0;
      PI_input_B_X <= 18'b000100000000000000;
      PI_input_C_Z <= 18'b100001000000000000;
      PI_input_C_X <= 18'b000000000000000000;
      PI_input_B_Y <= 18'b100010101010000001;
      PI_input_A_Z <= 18'b000000000100000000;
      PI_input_A_X <= 18'b000100000000001000;
      PI_run <= 1'b1;
      PI_input_B_Z <= 18'b001000100100100001;
      PI_instruction_start_pointer <= 5'b10000;
      PI_input_A_Y <= 18'b100000000000000000;
      PI_input_C_Y <= 18'b110000000000000000;
    end

    // state 2
    if (cycle == 1) begin
      PI_rst <= 1'b0;
      PI_input_B_X <= 18'b100000000000000000;
      PI_input_C_Z <= 18'b100000100000000001;
      PI_input_C_X <= 18'b100000000000000001;
      PI_input_B_Y <= 18'b100000000000000000;
      PI_input_A_Z <= 18'b100000000000000001;
      PI_input_A_X <= 18'b100000000000000001;
      PI_run <= 1'b0;
      PI_input_B_Z <= 18'b100000000000000001;
      PI_instruction_start_pointer <= 5'b10000;
      PI_input_A_Y <= 18'b100000000000000001;
      PI_input_C_Y <= 18'b100000000000000001;
    end

    // state 3
    if (cycle == 2) begin
      PI_rst <= 1'b0;
      PI_input_B_X <= 18'b100000000001000000;
      PI_input_C_Z <= 18'b100000000000000001;
      PI_input_C_X <= 18'b100000000000000001;
      PI_input_B_Y <= 18'b100000000000000001;
      PI_input_A_Z <= 18'b100000000000000001;
      PI_input_A_X <= 18'b100000000000000001;
      PI_run <= 1'b1;
      PI_input_B_Z <= 18'b100000000000000001;
      PI_instruction_start_pointer <= 5'b10001;
      PI_input_A_Y <= 18'b100000000000000001;
      PI_input_C_Y <= 18'b100000000000000001;
    end

    // state 4
    if (cycle == 3) begin
      PI_rst <= 1'b0;
      PI_input_B_X <= 18'b100000000000000001;
      PI_input_C_Z <= 18'b100000000000000001;
      PI_input_C_X <= 18'b100000000000000001;
      PI_input_B_Y <= 18'b100000000000000001;
      PI_input_A_Z <= 18'b000000000000000001;
      PI_input_A_X <= 18'b100000000000000001;
      PI_run <= 1'b1;
      PI_input_B_Z <= 18'b100000010000000000;
      PI_instruction_start_pointer <= 5'b01100;
      PI_input_A_Y <= 18'b100000000000000001;
      PI_input_C_Y <= 18'b100000000000000001;
    end

    // state 5
    if (cycle == 4) begin
      PI_rst <= 1'b0;
      PI_input_B_X <= 18'b100000000000000001;
      PI_input_C_Z <= 18'b100000000000000001;
      PI_input_C_X <= 18'b100000000000000001;
      PI_input_B_Y <= 18'b100000000000000001;
      PI_input_A_Z <= 18'b100000000000000001;
      PI_input_A_X <= 18'b100000000000000001;
      PI_run <= 1'b0;
      PI_input_B_Z <= 18'b100000000000000001;
      PI_instruction_start_pointer <= 5'b00000;
      PI_input_A_Y <= 18'b100000000000000001;
      PI_input_C_Y <= 18'b100000000000000001;
    end

    // state 6
    if (cycle == 5) begin
      PI_rst <= 1'b0;
      PI_input_B_X <= 18'b100010000000000000;
      PI_input_C_Z <= 18'b100000000000000010;
      PI_input_C_X <= 18'b100000001000000000;
      PI_input_B_Y <= 18'b100000000000000000;
      PI_input_A_Z <= 18'b100000000000000001;
      PI_input_A_X <= 18'b100000000000000001;
      PI_run <= 1'b0;
      PI_input_B_Z <= 18'b100000000000000000;
      PI_instruction_start_pointer <= 5'b00000;
      PI_input_A_Y <= 18'b000000011100100000;
      PI_input_C_Y <= 18'b100000000000100000;
    end

    // state 7
    if (cycle == 6) begin
      PI_rst <= 1'b0;
      PI_input_B_X <= 18'b000000000010000000;
      PI_input_C_Z <= 18'b110111110000010001;
      PI_input_C_X <= 18'b100000000000000001;
      PI_input_B_Y <= 18'b110111110000000000;
      PI_input_A_Z <= 18'b110000000000000000;
      PI_input_A_X <= 18'b000000100000000000;
      PI_run <= 1'b1;
      PI_input_B_Z <= 18'b010000000000000000;
      PI_instruction_start_pointer <= 5'b10101;
      PI_input_A_Y <= 18'b110000011100000000;
      PI_input_C_Y <= 18'b110111110000010001;
    end

    // state 8
    if (cycle == 7) begin
      PI_rst <= 1'b0;
      PI_input_B_X <= 18'b000000000000000100;
      PI_input_C_Z <= 18'b100000100000000000;
      PI_input_C_X <= 18'b000000000000000001;
      PI_input_B_Y <= 18'b000000000000000100;
      PI_input_A_Z <= 18'b100000010000000000;
      PI_input_A_X <= 18'b100000000001000000;
      PI_run <= 1'b1;
      PI_input_B_Z <= 18'b100000000000000001;
      PI_instruction_start_pointer <= 5'b11010;
      PI_input_A_Y <= 18'b011101011010101110;
      PI_input_C_Y <= 18'b100000000000000100;
    end

    // state 9
    if (cycle == 8) begin
      PI_rst <= 1'b0;
      PI_input_B_X <= 18'b100000000100000000;
      PI_input_C_Z <= 18'b000000100000000000;
      PI_input_C_X <= 18'b100000010000000000;
      PI_input_B_Y <= 18'b100000100000000000;
      PI_input_A_Z <= 18'b000000000000000000;
      PI_input_A_X <= 18'b000000000001000000;
      PI_run <= 1'b1;
      PI_input_B_Z <= 18'b100000010000000000;
      PI_instruction_start_pointer <= 5'b00000;
      PI_input_A_Y <= 18'b100001000000000000;
      PI_input_C_Y <= 18'b000000001000000000;
    end

    // state 10
    if (cycle == 9) begin
      PI_rst <= 1'b0;
      PI_input_B_X <= 18'b100010000000000000;
      PI_input_C_Z <= 18'b000000000001000000;
      PI_input_C_X <= 18'b000000100000000000;
      PI_input_B_Y <= 18'b100000000001000000;
      PI_input_A_Z <= 18'b100000000100000000;
      PI_input_A_X <= 18'b100000001000000000;
      PI_run <= 1'b1;
      PI_input_B_Z <= 18'b100000000000001000;
      PI_instruction_start_pointer <= 5'b00001;
      PI_input_A_Y <= 18'b100000100000000000;
      PI_input_C_Y <= 18'b011100000000000000;
    end

    // state 11
    if (cycle == 10) begin
      PI_rst <= 1'b0;
      PI_input_B_X <= 18'b100000001000000000;
      PI_input_C_Z <= 18'b100000000000010000;
      PI_input_C_X <= 18'b100000100000000000;
      PI_input_B_Y <= 18'b100000000000010000;
      PI_input_A_Z <= 18'b000111111111100100;
      PI_input_A_X <= 18'b010111001000000000;
      PI_run <= 1'b1;
      PI_input_B_Z <= 18'b000000010000000000;
      PI_instruction_start_pointer <= 5'b00000;
      PI_input_A_Y <= 18'b001010110111100000;
      PI_input_C_Y <= 18'b000000000000001000;
    end

    // state 12
    if (cycle == 11) begin
      PI_rst <= 1'b0;
      PI_input_B_X <= 18'b101100001001100100;
      PI_input_C_Z <= 18'b100000000001000000;
      PI_input_C_X <= 18'b000000000000001000;
      PI_input_B_Y <= 18'b100000000000000000;
      PI_input_A_Z <= 18'b000010000000000000;
      PI_input_A_X <= 18'b001000000000000000;
      PI_run <= 1'b1;
      PI_input_B_Z <= 18'b111110101110010000;
      PI_instruction_start_pointer <= 5'b00000;
      PI_input_A_Y <= 18'b010000000000000000;
      PI_input_C_Y <= 18'b101000000000000000;
    end

    // state 13
    if (cycle == 12) begin
      PI_rst <= 1'b0;
      PI_input_B_X <= 18'b110000000000000000;
      PI_input_C_Z <= 18'b101000000000000000;
      PI_input_C_X <= 18'b100000000100000000;
      PI_input_B_Y <= 18'b100000000010000000;
      PI_input_A_Z <= 18'b000000010000000000;
      PI_input_A_X <= 18'b101000000000000000;
      PI_run <= 1'b1;
      PI_input_B_Z <= 18'b100010000000000000;
      PI_instruction_start_pointer <= 5'b00000;
      PI_input_A_Y <= 18'b100000000000000001;
      PI_input_C_Y <= 18'b100001000000000000;
    end

    // state 14
    if (cycle == 13) begin
      PI_rst <= 1'b0;
      PI_input_B_X <= 18'b100000000000000001;
      PI_input_C_Z <= 18'b100000100000000000;
      PI_input_C_X <= 18'b100000000000000100;
      PI_input_B_Y <= 18'b001000000000000000;
      PI_input_A_Z <= 18'b100000010000000000;
      PI_input_A_X <= 18'b100000000000000100;
      PI_run <= 1'b1;
      PI_input_B_Z <= 18'b100000000001000000;
      PI_instruction_start_pointer <= 5'b00000;
      PI_input_A_Y <= 18'b100000000100000000;
      PI_input_C_Y <= 18'b001000000000000000;
    end

    // state 15
    if (cycle == 14) begin
      PI_rst <= 1'b0;
      PI_input_B_X <= 18'b100000000000000001;
      PI_input_C_Z <= 18'b100000000000000001;
      PI_input_C_X <= 18'b100000000000000001;
      PI_input_B_Y <= 18'b100000000000000001;
      PI_input_A_Z <= 18'b100000000000000001;
      PI_input_A_X <= 18'b100000000000000001;
      PI_run <= 1'b1;
      PI_input_B_Z <= 18'b100000000000000001;
      PI_instruction_start_pointer <= 5'b00000;
      PI_input_A_Y <= 18'b100000000000000001;
      PI_input_C_Y <= 18'b100000000000000001;
    end

    genclock <= cycle < 15;
    cycle <= cycle + 1;
  end
endmodule
