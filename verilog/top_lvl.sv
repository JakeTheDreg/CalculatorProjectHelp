/* 
 * This top_level module integrates the controller, memory, adder, and result buffer to form a complete calculator system.
 * It handles memory reads/writes, arithmetic operations, and result buffering.
 */
import calculator_pkg::*;
module top_lvl (
    input  logic                 clk,
    input  logic                 rst,

    // Memory Config
    input  logic [ADDR_W-1:0]    read_start_addr,
    input  logic [ADDR_W-1:0]    read_end_addr,
    input  logic [ADDR_W-1:0]    write_start_addr,
    input  logic [ADDR_W-1:0]    write_end_addr

    

    
);

    //Any wires, combinational assigns, etc should go at the top for visibility
    //controller wires
    logic write, 
    logic read;
    logic [ADDR_W-1:0] w_addr, 
    logic [ADDR_W-1:0] r_addr;
    logic [MEM_WORD_SIZE-1:0] w_data, 
    logic [MEM_WORD_SIZE-1:0] r_data;
    logic [DATA_W-1:0] op_a, 
    logic [DATA_W-1:0] op_b;
    logic [MEM_WORD_SIZE-1:0] buff_result;  
    //SRAM wire
    logic wmask0 = 4'hF;

    //TODO: Finish instantiation of your controller module
	controller u_ctrl (
  //inputs
  .clk_i(clk),
  .rst_i(rst),
  .read_start_addr(read_start_addr),
  .read_end_addr(read_end_addr),
  .write_start_addr(write_start_addr),
  .write_end_addr(write_end_addr),
  .r_data(r_data),
  .buff_result(buff_result),

  //outputs
  .write(write),
  .w_addr(w_addr),
  .w_data(w.data),
  .buffer_control(buffer_control),  //1 = upper, 0= lower
  .op_a(op_a),
  .op_b(op_b),


  );

    //TODO: Look at the sky130_sram_2kbyte_1rw1r_32x512_8 module and instantiate it using variables defined above.
    // Note: This module has two ports, port 0 for read and write and port 1 for read only. We are using port 0 writing and port 1 for reading in this design.    
    // we have provided all of the input ports of SRAM_A, which you will need to connect to calculator ports inside the parentheses. 
    // Your instantiation for SRAM_A will be similar to SRAM_B. 
  	/*
     * .clk0 : sram macro clock input. Connect to same clock as controller.sv. 
     * .csb0 : chip select, active low. Set low when you want to write. Refer to sky130_sram instantiation to see what value to use for both read and write operations in port 0.
     * .web0 : write enable, active low. Set low when you want to write.  Refer to sky130_sram instantiation to see what value to use for both read and write operations in port 0.
     * .wmask0 : write mask, used to select which bits to write. For this design, we will write all bits, so use 4'hF.
     * .addr0 : address to read/write
     * .din0 : data to write
     * .dout0 : data output from memory when performing a read. Will leave blank here because we are only writing to port 0. 
     * .clk1  : sram macro clock input for port 2. Connect to same clock as controller.sv. 
     * .csb1  : chip select, active low. Set low when you want to read. Since this second port can only be used to read, there is no write enable bit (web) 
     * .addr1 : address to read from. You will supply this value. 
     * .dout1 : data output from the SRAM macro port.
     */
  	
      sky130_sram_2kbyte_1rw1r_32x512_8 sram_A (
        .clk0   (clk),  
        .csb0   ((read | write)),
        .web0   (write), 
        .wmask0 (wmask0), 
        .addr0  (w_addr), //maybe r_addr 
        .din0   (w_data),
        .dout0  (), //leave blank
        .clk1   (clk), 
        .csb1   (read), 
        .addr1  (r_addr), 
        .dout1  (r_data) 
    );

  
    //TODO: Instantiate the second SRAM for the lower half of the memory.
    sky130_sram_2kbyte_1rw1r_32x512_8 sram_B (
        .clk0   (clk),  
        .csb0   ((read | write)),
        .web0   (write), 
        .wmask0 (wmask0), 
        .addr0  (w_addr), //maybe r_addr 
        .din0   (w_data),
        .dout0  (), //leave blank
        .clk1   (clk), 
        .csb1   (read), 
        .addr1  (r_addr), 
        .dout1  (r_data) 
    );
  	
  	//TODO: Finish instantiation of your adder module
    adder32 u_adder (
      .a_i(op_a), //input from srama
      .b_i(op_b), //input from sramb
      .sum_o(sum_o) //output to buffer
    );
 
    //TODO: Finish instantiation of your result buffer
    result_buffer u_resbuf (
      .clk0(clk),
      
      .result_i(sum_o), //input from adder
      .loc_sel(buffer_control),  //input
      .buffer_o(w_data)  //output to sram
    );

endmodule
