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
* @file   single_channel_memory.sv
* @author Anthony Kung <hi@anth.dev> (anth.dev)
* @date   Created on 06/03/2023 18:26:45 PM
*/


module single_channel_memory #(
  parameter DATA_WIDTH = 8,
  parameter MAX_IMAGE_SIZE = 512,
  parameter MAX_IMAGE_SIZE_LOG2 = 9
) (
  input wire clk,
  input wire we,
  input wire rst,  // active high reset following wishbone standard
  input wire [DATA_WIDTH-1:0] input_data,
  input wire [MAX_IMAGE_SIZE_LOG2:0] cell_x,
  input wire [MAX_IMAGE_SIZE_LOG2:0] cell_y,
  output wire [DATA_WIDTH-1:0] output_data
);

  // Memory block 512x512 padded 1 with 8-bit data
  reg [DATA_WIDTH - 1:0] memory [MAX_IMAGE_SIZE + 1:0][MAX_IMAGE_SIZE + 1:0];

  // Initialize the boundary cells to 0
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      for (integer i = 0; i < MAX_IMAGE_SIZE + 1; i = i + 1) begin
        memory[i][0] <= 0;
        memory[i][MAX_IMAGE_SIZE + 1] <= 0;
        memory[0][i] <= 0;
        memory[MAX_IMAGE_SIZE + 1][i] <= 0;
      end
    end
  end

  // Read and write logic
  always @(posedge clk) begin
    if (we) begin
      memory[cell_x][cell_y] <= input_data;
    end
    else begin
      output_data <= memory[cell_x][cell_y];
    end
  end

endmodule