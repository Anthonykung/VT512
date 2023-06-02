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
* @file   Pooling.sv
* @author Anthony Kung <hi@anth.dev> (anth.dev)
* @date   Created on 06/02/2023 13:22:04 PM
*/


module PoolingLayer #(
    parameter integer DATA_WIDTH = 8,
    parameter integer KERNEL_SIZE = 2,
    parameter integer INPUT_CHANNELS = 1
)(
    input wire [DATA_WIDTH-1:0] input_data,
    output wire [DATA_WIDTH-1:0] output_data
);
  localparam integer INPUT_SIZE = DATA_WIDTH * DATA_WIDTH * INPUT_CHANNELS;
  localparam integer OUTPUT_SIZE = (DATA_WIDTH/KERNEL_SIZE) * (DATA_WIDTH/KERNEL_SIZE) * INPUT_CHANNELS;

  wire [DATA_WIDTH-1:0] pooled_pixel;

  genvar i, j, k;
  generate
    for (i = 0; i < INPUT_CHANNELS; i = i + 1) begin : channel_loop
      for (j = 0; j < DATA_WIDTH/KERNEL_SIZE; j = j + 1) begin : row_loop
        for (k = 0; k < DATA_WIDTH/KERNEL_SIZE; k = k + 1) begin : col_loop
          assign pooled_pixel = 0;
          assign pooled_pixel = $unsigned(input_data[(j * KERNEL_SIZE) * DATA_WIDTH + (k * KERNEL_SIZE)]);
          if (KERNEL_SIZE > 1) begin
            for (genvar m = 0; m < KERNEL_SIZE; m = m + 1) begin : pool_row_loop
              for (genvar n = 0; n < KERNEL_SIZE; n = n + 1) begin : pool_col_loop
                if (input_data[(j * KERNEL_SIZE + m) * DATA_WIDTH + (k * KERNEL_SIZE + n)] > pooled_pixel) begin
                  assign pooled_pixel = $unsigned(input_data[(j * KERNEL_SIZE + m) * DATA_WIDTH + (k * KERNEL_SIZE + n)]);
                end
              end
            end
          end
          assign output_data[i * (DATA_WIDTH/KERNEL_SIZE) * (DATA_WIDTH/KERNEL_SIZE) + (j * (DATA_WIDTH/KERNEL_SIZE)) + k] = pooled_pixel;
        end
      end
    end
  endgenerate

endmodule
