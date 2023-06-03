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
* @file   cnn_top.sv
* @author Anthony Kung <hi@anth.dev> (anth.dev)
* @date   Created on 06/01/2023 01:05:58 AM
*/


module cnn_top #(
  parameter DATA_WIDTH = 32,
  parameter ADDR_WIDTH = 32,
  parameter MAX_IMAGE_SIZE = 512,
  parameter MAX_IMAGE_SIZE_LOG2 = 9
)(
  input wire data_clk,  // Image data sampling clock (connected to wishbone clock)
  input wire size_detection_done,  // Detection Done, Image Size is ready and Image Data is streaming in
  input wire [DATA_WIDTH-1:0] image_data,  // Image data
  input wire [MAX_IMAGE_SIZE_LOG2:0] image_size,  // Image size output
  output wire [CHANNELS-1:0] extracted_features_out
);
  // Define the parameters for MobileNetV3 Small
  parameter CHANNELS = 1280;
  parameter KERNEL_SIZE = 3;
  parameter STRIDE = 1;
  parameter PADDING = 1;
  parameter EXPANSION_FACTOR = 6;
  parameter NUM_BLOCKS = 5;

  // Define the internal registers and wires
  reg [DATA_WIDTH-1:0] image_buffer [0:MAX_IMAGE_SIZE-1][0:MAX_IMAGE_SIZE-1];
  wire [DATA_WIDTH-1:0] image_pixel;
  wire [DATA_WIDTH-1:0] conv_result;
  reg [DATA_WIDTH-1:0] conv_buffer [0:MAX_IMAGE_SIZE-1][0:MAX_IMAGE_SIZE-1];
  reg [DATA_WIDTH-1:0] output_buffer [0:MAX_IMAGE_SIZE-1][0:MAX_IMAGE_SIZE-1];
  reg [DATA_WIDTH-1:0] pooled_feature;

  // Convolutional layer
  generate
    genvar i;
    for (i = 0; i < NUM_BLOCKS; i = i + 1) begin : block
      // Expansion convolution
      ConvolutionLayer #(
        .DATA_WIDTH(DATA_WIDTH),
        .KERNEL_SIZE(KERNEL_SIZE),
        .STRIDE(STRIDE),
        .PADDING(PADDING),
        .INPUT_CHANNELS(CHANNELS / EXPANSION_FACTOR),
        .OUTPUT_CHANNELS(CHANNELS / EXPANSION_FACTOR),
        .IMAGE_SIZE(MAX_IMAGE_SIZE),
        .IMAGE_SIZE_LOG2(MAX_IMAGE_SIZE_LOG2)
      ) expansion_conv (
        .input_data(conv_buffer),
        .output_data(conv_result)
      );

      // Depthwise convolution
      ConvolutionLayer #(
        .DATA_WIDTH(DATA_WIDTH),
        .KERNEL_SIZE(KERNEL_SIZE),
        .STRIDE(STRIDE),
        .PADDING(PADDING),
        .INPUT_CHANNELS(CHANNELS / EXPANSION_FACTOR),
        .OUTPUT_CHANNELS(CHANNELS / EXPANSION_FACTOR),
        .IMAGE_SIZE(MAX_IMAGE_SIZE),
        .IMAGE_SIZE_LOG2(MAX_IMAGE_SIZE_LOG2)
      ) depthwise_conv (
        .input_data(conv_result),
        .output_data(conv_buffer)
      );
    end
  endgenerate

  // Pooling layer
  PoolingLayer #(
    .DATA_WIDTH(DATA_WIDTH),
    .KERNEL_SIZE(2),
    .STRIDE(2),
    .INPUT_CHANNELS(CHANNELS / EXPANSION_FACTOR),
    .OUTPUT_CHANNELS(CHANNELS / EXPANSION_FACTOR),
    .IMAGE_SIZE(MAX_IMAGE_SIZE),
    .IMAGE_SIZE_LOG2(MAX_IMAGE_SIZE_LOG2)
  ) pooling (
    .input_data(conv_buffer),
    .output_data(pooled_feature)
  );

  // Assign the output feature
  always @(posedge clk) begin
    if (size_detection_done) begin
      extracted_features_out <= pooled_feature;
    end
  end

endmodule

