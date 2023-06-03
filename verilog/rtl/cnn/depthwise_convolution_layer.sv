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
* @file   Depthwise.sv
* @author Anthony Kung <hi@anth.dev> (anth.dev)
* @date   Created on 06/02/2023 13:18:43 PM
*/


module depthwise_convolution_layer #(
  parameter integer DATA_WIDTH = 8,
  parameter integer KERNEL_SIZE = 3,
  parameter integer INPUT_CHANNELS = 3,
  parameter integer CHANNEL_MULTIPLIER = 1
)(
  input wire [DATA_WIDTH-1:0] input_data,
  output wire [DATA_WIDTH-1:0] output_data
);
  localparam integer INPUT_SIZE = DATA_WIDTH * DATA_WIDTH * INPUT_CHANNELS;
  localparam integer OUTPUT_CHANNELS = INPUT_CHANNELS * CHANNEL_MULTIPLIER;
  localparam integer OUTPUT_SIZE = DATA_WIDTH * DATA_WIDTH * OUTPUT_CHANNELS;

  wire [DATA_WIDTH-1:0] kernel[KERNEL_SIZE*KERNEL_SIZE-1:0][INPUT_CHANNELS-1:0];

  // Implement the depthwise convolution operation
  wire [DATA_WIDTH-1:0] output_pixel;

  genvar i, j, k, l;
  generate
    for (i = 0; i < OUTPUT_CHANNELS; i = i + 1) begin : channel_loop
      assign output_pixel = 0;
      for (j = 0; j < KERNEL_SIZE; j = j + 1) begin : row_loop
        for (k = 0; k < KERNEL_SIZE; k = k + 1) begin : col_loop
          for (l = 0; l < INPUT_CHANNELS; l = l + 1) begin : input_channel_loop
            assign output_pixel = output_pixel + (input_data[j * DATA_WIDTH + k] * kernel[j][l]);
          end
        end
      end
      assign output_data[i * DATA_WIDTH * DATA_WIDTH +: DATA_WIDTH * DATA_WIDTH] = output_pixel;
    end
  endgenerate

endmodule
