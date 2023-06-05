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
* @file   weight_memory.sv
* @author Anthony Kung <hi@anth.dev> (anth.dev)
* @date   Created on 06/05/2023 01:41:19 AM
*/


module weight_memory #(
  parameter DATA_WIDTH = 8,
  parameter DATA_SIZE = 2,
  parameter CHANNELS = 3,
  parameter CHANNELS_LOG2 = 2
) (
  input wire clk,
  input wire we,
  input wire [DATA_SIZE:0] row_wr[CHANNELS_LOG2 - 1:0],  // write address
  input wire [DATA_SIZE:0] col_wr[CHANNELS_LOG2 - 1:0],
  input wire [DATA_SIZE:0] channel_wr[CHANNELS_LOG2 - 1:0],
  input wire [DATA_WIDTH - 1:0] input_data[CHANNELS_LOG2 - 1:0],
  input wire [DATA_SIZE:0] row_rd[CHANNELS_LOG2 - 1:0],  // read address
  input wire [DATA_SIZE:0] col_rd[CHANNELS_LOG2 - 1:0],
  input wire [DATA_SIZE:0] channel_rd[CHANNELS_LOG2 - 1:0],
  output wire [DATA_WIDTH - 1:0] output_data[CHANNELS_LOG2 - 1:0]
);

  // Memory block 3x3x3 with 8-bit data
  reg [DATA_WIDTH - 1:0] memory [DATA_SIZE:0][DATA_SIZE:0][DATA_SIZE:0];

  // Initialize memory cells
  always @(posedge clk) begin
    if (we) begin
      for (int i = 0; i < CHANNELS; i = i + 1) begin
        memory[row_wr[i]][col_wr[i]][channel_wr[i]] <= input_data[i];
      end
    end
  end

  // Output data from memory
  assign output_data = {memory[row_rd[2]][col_rd[2]][channel_rd[2]], memory[row_rd[1]][col_rd[1]][channel_rd[1]], memory[row_rd[0]][col_rd[0]][channel_rd[0]]};

endmodule