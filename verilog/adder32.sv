/*
* Module describing a 32-bit ripple carry adder, with no carry output or input
*/
import calculator_pkg::*;
module adder32 (
    input logic [DATA_W - 1 : 0] a_i,
    input logic [DATA_W - 1 : 0] b_i,
    output logic [DATA_W - 1 : 0] sum_o
);

    //TODO: use a generate block to chain together 32 full adders. 
    // Imagine you are connecting 32 single-bit adder modules together. 
    logic [DATA_W:0] c; 
    assign c[0] = 1'b0; 

    genvar i;
    generate
        for (i = 0; i <  32; i = i + 1) begin
	        full_adder fa_inst (
                .a      (a_i[i]),
                .b      (b_i[i]),
                .cin    (i == 0 ? 1'b0 : c[i-1]),
                .s      (sum_o[i]),
                .cout   (c[i+1])
            );
	    end 
    endgenerate
endmodule
