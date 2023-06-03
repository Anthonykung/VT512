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
* @file   conv3x3.sv
* @author Anthony Kung <hi@anth.dev> (anth.dev)
* @date   Created on 06/02/2023 18:41:37 PM
*/


module conv3x3 (
  input [2:0][2:0][7:0] input,
  input [7:0] weight [2:0][2:0],
  output [7:0] output
);
  reg [15:0] sum;
  integer i, j, k;

  always @* begin
    sum = 0;
    for (i = 0; i < 3; i = i + 1) begin
      for (j = 0; j < 3; j = j + 1) begin
        for (k = 0; k < 3; k = k + 1) begin
          sum = sum + input[i][j][k] * weight[i][j];
        end
      end
    end
    output = sum[7:0];
  end
endmodule
