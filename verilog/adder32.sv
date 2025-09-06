/*
* Module describing a 32-bit ripple carry adder, with no carry output or input
*/
module adder32 import calculator_pkg::*; (
    input logic [DATA_W - 1 : 0] a_i,
    input logic [DATA_W - 1 : 0] b_i,
    output logic [DATA_W - 1 : 0] sum_o
);

    //TODO: use a generate block to chain together 32 full adders. 
    // Imagine you are connecting 32 single-bit adder modules together. 
    
    //this generates 32 full adders with the assigned bit of i. 
    genvar i;
    generate
        for (i = 0 ; i < 31; i= + 1) begin
            full_adder (a_i[i], b_i[i], sum_o[i])
        end
    endgenerate

endmodule