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
  parameter DATA_WIDTH = 24,
  parameter MAX_IMAGE_SIZE = 512,
  parameter MAX_IMAGE_SIZE_LOG2 = 9
) (
`ifdef USE_POWER_PINS
  inout vccd1,	// User area 1 1.8V supply
  inout vssd1,	// User area 1 digital ground
`endif

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

  input dt24_clk_i,
  input dt24_we_i,
  input [23:0] dt24_data_i,
  output dt24_clk_o,
  output dt24_we_o,
  output [23:0] dt24_data_o,
  output dt24_clk_oenb,  // Active low
  output dt24_we_oenb,  // Active low
  output [23:0] dt24_data_oenb  // Active low
);

  // Control register
  // [0] - 0: 1 Image Channel, 1: 3 Image Channel
  // [1] - 0: 3x3 Filter, 1: 4x4 Filter
  // [5:2] - First Layer Filter Depth
  // [6] - 0: Filter Depth Multiply, 1: Filter Depth Add
  // [10:7] - Filter Depth Offset to Multiply/Add by First Layer Filter Depth
  // [14:11] - Number of Convolutional Layers
  // [18:15] - Number of Pooling Layers
  // [22:19] - Pooling Layer Interval
  // [23] - 0: Output Labels, 1: Output Image
  reg [DATA_WIDTH-1:0] control_reg;
  reg [DATA_WIDTH-1:0] cnn_control_reg;

  reg [DATA_WIDTH-1:0] image_data_out;
  reg [MAX_IMAGE_SIZE_LOG2:0] image_size;
  reg [MAX_IMAGE_SIZE_LOG2:0] row_counter;
  reg size_detection_done;  // Done within the image capture state machine
  reg image_done;  // Done within the image capture state machine
  reg cnn_done;  // Done within the CNN state machine
  reg vit_done;  // Done within the VIT state machine

  // Define the states as an enumerated data type
  typedef enum logic [3:0] {
    IDLE_STATE,
    CONFIG_STATE,  // Set up configuration registers
    WEIGHTS_STATE,  // Set up weights
    BIASES_STATE,  // Set up biases
    IMAGE_STATE,  // Image Capture
    CNN_STATE,  // CNN State, CNN includes internal state machine
    VIT_STATE,  // VIT State, VIT includes internal state machine
    DONE_STATE  // Done
    // Add other states here...
  } StateType;

  // Internal signals
  StateType current_state;
  StateType next_state;
  reg [DATA_WIDTH-1:0] current_address;

  // Address and data registers
  reg [2:0] img_we;
  reg [MAX_IMAGE_SIZE_LOG2:0] img_row_wr[2:0];
  reg [MAX_IMAGE_SIZE_LOG2:0] img_col_wr[2:0];
  reg [DATA_WIDTH-1:0] img_input_data[2:0];
  reg [MAX_IMAGE_SIZE_LOG2:0] img_row_rd[2:0];
  reg [MAX_IMAGE_SIZE_LOG2:0] img_col_rd[2:0];
  wire [DATA_WIDTH-1:0] img_output_data[2:0];

  // Instantiate single_channel_memory modules
  generate
    genvar i;
    for (i = 0; i < 3; i = i + 1) begin : mem_inst
      single_channel_memory #(
        .DATA_WIDTH(DATA_WIDTH),
        .MAX_IMAGE_SIZE(MAX_IMAGE_SIZE),
        .MAX_IMAGE_SIZE_LOG2(MAX_IMAGE_SIZE_LOG2)
      ) mem (
        .clk(dt24_clk_i),
        .we(img_we[i]),
        .row_wr(img_row_wr[i]),
        .col_wr(img_col_wr[i]),
        .input_data(img_input_data[i]),
        .row_rd(img_row_rd[i]),
        .col_rd(img_col_rd[i]),
        .output_data(img_output_data[i])
      );
    end
  endgenerate

  // Reset
  always @(posedge dt24_clk_i or posedge wb_rst_i) begin
    if (wb_rst_i) begin
      current_state <= IDLE_STATE;
      next_state <= IDLE_STATE;
    end
    else begin
      current_state <= next_state;
    end
  end

  // State machine
  always @(posedge dt24_clk_i) begin
    case (current_state)
      IDLE_STATE:
        current_address <= 0;
        control_reg <= 0;
        cnn_control_reg <= 0;
        // if write enable, get the address
        if (dt24_we_i) begin
          current_address <= dt24_data_i;
          if (current_address == 1) begin
            next_state <= CONFIG_STATE;
          end
          else if (current_address == 2) begin
            next_state <= WEIGHTS_STATE;
          end
          else if (current_address == 3) begin
            next_state <= BIASES_STATE;
          end
          else if (current_address == 4) begin
            next_state <= IMAGE_STATE;
          end
          else begin
            next_state <= IDLE_STATE;
          end
        end
        else begin
          next_state <= IDLE_STATE;
        end
      CONFIG_STATE:
        // if write enable, get the data
        if (dt24_we_i) begin
          control_reg <= dt24_data_i;
          // Control Reg [0] 1 is Reuse Weights skip WEIGHTS_STATE
          // Control Reg [1] 1 is Reuse Biases skip BIASES_STATE
          if (control_reg[0] == 1) begin
            next_state <= BIASES_STATE;
          end
          else if (control_reg[1] == 1) begin
            next_state <= WEIGHTS_STATE;
          end
          else if (control_reg[0] == 1 && control_reg[1] == 1) begin
            next_state <= IMAGE_STATE;
          end
          else begin
            next_state <= WEIGHTS_STATE;
          end
        end
        else begin
          next_state <= CONFIG_STATE;
        end
      WEIGHTS_STATE:
        // if write enable, get the data
        if (dt24_we_i) begin
          next_state <= IDLE_STATE;
        end
        else begin
          next_state <= WEIGHTS_STATE;
        end
      // Add other states and transitions here...
    endcase
  end

endmodule
