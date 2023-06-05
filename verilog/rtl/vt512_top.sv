/**
* Copyright (c) 2023 Anthony Kung (anth.dev)
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     https://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*
* @file   vt_top.sv
* @author Anthony Kung <hi@anth.dev> (anth.dev)
* @date   Created on 05/31/2023 23:14:09 PM
*/


module vt512_top #(
  parameter DATA_WIDTH = 32,
  parameter MAX_IMAGE_SIZE = 512
) (
`ifdef USE_POWER_PINS
  inout vccd1,	// User area 1 1.8V supply
  inout vssd1,	// User area 1 digital ground
`endif

  // Clock
  // input user_clock2, // 40 MHz

  // Wishbone Slave ports (WB MI A)
  input wb_clk_i, // 40 MHz
  input wb_rst_i,
  input wbs_stb_i,
  input wbs_cyc_i,
  input wbs_we_i,
  input [3:0] wbs_sel_i,
  input [31:0] wbs_dat_i,
  input [31:0] wbs_adr_i,
  output wbs_ack_o,
  output [31:0] wbs_dat_o,

  // Logic Analyzer Signals
  // input  [127:0] la_data_in,
  // output [127:0] la_data_out,
  // input  [127:0] la_oenb,

  // IOs [37:5] usable [4:0] reserved for SPI
  // IO[0]: JTAG
  // IO[1]: SDO data out
  // IO[2]: SDI data in
  // IO[3]: CSB chip select
  // IO[4]: SCK clock
  input  [`MPRJ_IO_PADS-1:0] io_in,
  output [`MPRJ_IO_PADS-1:0] io_out,
  output [`MPRJ_IO_PADS-1:0] io_oeb,  // Output Enable active low

  // IRQ
  // output [2:0] irq
);

  // Control register
  reg [31:0] control_reg;

  reg [DATA_WIDTH-1:0] image_data_out;
  reg [MAX_IMAGE_SIZE_LOG2:0] image_size;
  reg size_detection_done;
  reg [MAX_IMAGE_SIZE_LOG2:0] row_counter;

  // Define the states as an enumerated data type
  typedef enum logic [3:0] {
    IDLE_STATE,
    CONFIG_STATE,
    WEIGHTS_STATE,
    BIASES_STATE,
    IMAGE_STATE,
    // Add other states here...
  } StateType;

  // Internal signals
  StateType current_state;
  StateType next_state;
  reg [31:0] current_address;

  // State machine
  always @(posedge clk, posedge reset) begin
    if (reset) begin
      current_state <= IDLE_STATE;
      current_address <= 0;
    end
    else begin
      current_state <= next_state;
      case (current_state)
        IDLE_STATE:
          if (gpio_data_valid) begin
            current_address <= gpio_data[31:4];
            case (current_address[3:0])
              // Add cases for other addresses here...
              default: next_state <= IDLE_STATE;
            endcase
          end
          // Add other states and transitions here...
      endcase
    end
  end

endmodule
