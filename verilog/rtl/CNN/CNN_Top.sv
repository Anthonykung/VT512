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


module CNN_Module #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter MAX_IMAGE_SIZE = 512,
    parameter MAX_IMAGE_SIZE_LOG2 = 9,
    parameter NUM_CLASSES = 1000,
    parameter NUM_FEATURES = 1280
)(
    input wire size_detection_done,
    input wire [DATA_WIDTH-1:0] image_data,
    input wire [MAX_IMAGE_SIZE_LOG2:0] image_size,
    output wire [NUM_FEATURES-1:0] extracted_features_out
);
    // Define your CNN architecture and implementation here
    // ...

    // Module for Convolutional Layer
    module ConvLayer #(
        parameter INPUT_CHANNELS = 3,
        parameter OUTPUT_CHANNELS = 16,
        parameter KERNEL_SIZE = 3,
        parameter STRIDE = 1
    )(
        input wire [INPUT_CHANNELS-1:0][MAX_IMAGE_SIZE-1:0][MAX_IMAGE_SIZE-1:0] input_feature_map,
        output wire [OUTPUT_CHANNELS-1:0][MAX_IMAGE_SIZE/STRIDE-1:0][MAX_IMAGE_SIZE/STRIDE-1:0] output_feature_map
    );
        // Implementation of convolutional layer
        // ...
    endmodule

    // Module for Depthwise Separable Convolution Layer
    module DepthwiseSeparableConvLayer #(
        parameter INPUT_CHANNELS = 16,
        parameter OUTPUT_CHANNELS = 16,
        parameter KERNEL_SIZE = 3,
        parameter STRIDE = 1
    )(
        input wire [INPUT_CHANNELS-1:0][MAX_IMAGE_SIZE/STRIDE-1:0][MAX_IMAGE_SIZE/STRIDE-1:0] input_feature_map,
        output wire [OUTPUT_CHANNELS-1:0][MAX_IMAGE_SIZE/STRIDE-1:0][MAX_IMAGE_SIZE/STRIDE-1:0] output_feature_map
    );
        // Implementation of depthwise separable convolution layer
        // ...
    endmodule

    // MobileNetV3 Architecture
    wire [3-1:0][MAX_IMAGE_SIZE-1:0][MAX_IMAGE_SIZE-1:0] conv1_output;
    wire [16-1:0][MAX_IMAGE_SIZE/2-1:0][MAX_IMAGE_SIZE/2-1:0] dw_conv1_output;
    wire [16-1:0][MAX_IMAGE_SIZE/2-1:0][MAX_IMAGE_SIZE/2-1:0] dw_conv2_output;
    wire [16-1:0][MAX_IMAGE_SIZE/2-1:0][MAX_IMAGE_SIZE/2-1:0] dw_conv3_output;
    wire [16-1:0][MAX_IMAGE_SIZE/2-1:0][MAX_IMAGE_SIZE/2-1:0] dw_conv4_output;
    // ...
    wire [NUM_FEATURES-1:0] feature_extraction_output;

    ConvLayer #(.INPUT_CHANNELS(3), .OUTPUT_CHANNELS(16)) conv1(.input_feature_map(image_data), .output_feature_map(conv1_output));
    DepthwiseSeparableConvLayer #(.INPUT_CHANNELS(16), .OUTPUT_CHANNELS(16)) dw_conv1(.input_feature_map(conv1_output), .output_feature_map(dw_conv1_output));
    DepthwiseSeparableConvLayer #(.INPUT_CHANNELS(16), .OUTPUT_CHANNELS(16)) dw_conv2(.input_feature_map(dw_conv1_output), .output_feature_map(dw_conv2_output));
    DepthwiseSeparableConvLayer #(.INPUT_CHANNELS(16), .OUTPUT_CHANNELS(16)) dw_conv3(.input_feature_map(dw_conv2_output), .output_feature_map(dw_conv3_output));
    DepthwiseSeparableConvLayer #(.INPUT_CHANNELS(16), .OUTPUT_CHANNELS(16)) dw_conv4(.input_feature_map(dw_conv3_output), .output_feature_map(dw_conv4_output));
    // ...
    // Complete the implementation of the rest of the MobileNetV3 architecture

    assign extracted_features_out = feature_extraction_output;

endmodule
