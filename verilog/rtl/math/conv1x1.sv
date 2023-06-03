module conv1x1 (
  input [7:0] input [2:0][2:0],
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
