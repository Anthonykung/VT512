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
* @file   image_capture.sv
* @author Anthony Kung <hi@anth.dev> (anth.dev)
* @date   Created on 05/31/2023 23:50:36 PM
*/

/**
* Image capture will capture one pixel at a time from the host and pass it to the CNN
* Each pixel is RGB which includes 8 bits for each color 24 bits in total
* The other 5 bits are used for the image size
*/

module image_capture #(
  parameter DATA_WIDTH = 32,
  parameter MAX_IMAGE_SIZE = 512,
  parameter MAX_IMAGE_SIZE_LOG2 = 9
) (
  input wire clk,
  input wire rst,
  input wire we_i,
  input wire [DATA_WIDTH-1:0] data_in,
  output wire ack_out,
  output wire [DATA_WIDTH-1:0] image_data_out,  // Image data output
  output wire [MAX_IMAGE_SIZE_LOG2:0] image_size,  // Image size output
  output wire size_detection_done
);

  // Wishbone interface
  always @(posedge wb_clk_i) begin
    if (wb_rst_i) begin
      wbs_ack_o <= 1'b0;
      wbs_dat_o <= 0;
      image_size <= 0;
      size_detection_done <= 0;
    end
    // If cycle and strobe and write enabled, write to the buffer
    else if (wbs_cyc_i && wbs_stb_i && wbs_we_i) begin
      // Acknowledge the write
      wbs_ack_o <= 1'b1;

      // If the size detection is not done, write the size
      if (!size_detection_done) begin
        image_size <= wbs_dat_i[MAX_IMAGE_SIZE_LOG2:0]; // Read image size from host
        if (image_size <= MAX_IMAGE_SIZE) begin
          size_detection_done <= 1;
        end
      end
      // Once we have the image size, we can start capturing image chunks and pass it to CNN
      else begin
        image_data_out <= wbs_dat_i;
      end
    end
    // else do nothing
    else begin
      wbs_ack_o <= 1'b0;
      wbs_dat_o <= 0;
    end
  end

endmodule
