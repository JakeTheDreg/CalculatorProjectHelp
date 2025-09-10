/*
* this contoller module controlls the flow of the FSM giving instructions based on the current_state the machine is in. 
* gives an overview of the function of the machine.
*/
import calculator_pkg::*;
module controller (
  	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	///////		Variables
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	input  logic              clk_i,
    input  logic              rst_i,
  
  	// Memory Access
    input  logic [ADDR_W-1:0] read_start_addr,
    input  logic [ADDR_W-1:0] read_end_addr,
    input  logic [ADDR_W-1:0] write_start_addr,
    input  logic [ADDR_W-1:0] write_end_addr,

  	// Writing Control
    output logic write,							//flag, when 0 = write.
    output logic [ADDR_W-1:0] w_addr,			//address to write data to
    output logic [MEM_WORD_SIZE-1:0] w_data,	//the data thats being written

	//Reading Controls
    input  logic [MEM_WORD_SIZE-1:0] r_data,	//data thats being read
	output logic read,							//flag, when 0 = read
    output logic [ADDR_W-1:0] r_addr,			//address thats being read from
	
	input  logic [MEM_WORD_SIZE-1:0] buff_result// the result thats being stored in the buffer and will be written to SRAM
    output logic              buffer_control,	// Buffer Control (1 = upper, 0, = lower)

  	output logic [DATA_W-1:0]       op_a,		//input into adder
    output logic [DATA_W-1:0]       op_b,		//input into adder
); 

	//TODO: Write your controller current_state machine as you see fit. 
	//HINT: See "6.2 Two Always BLock FSM coding style" from refmaterials/1_fsm_in_systemVerilog.pdf
	// This serves as a good starting point, but you might find it more intuitive to add more than two always blocks.

	typedef enum logic [2:0] {S_IDLE,S_READ,S_ADD,S_WRITE,S_END} current_state_t;
  	current_state_t current_state, next_state;
	logic [ADDR_W-1:0] curr_raddr,				//internal counter
	logic [ADDR_W-1:0] curr_waddr,				//internal counter
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	///////////// current_State Machine
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	always_ff @(posedge clk_i) begin
		if (rst_i) begin
			current_state <= S_IDLE;
		end else begin
			current_state = next_state;
		end
	end

	always_comb begin
		cases (current_state)
			S_IDLE:		next_state = S_READ;
			S_READ:		next_state = S_ADD;
			S_ADD:		next_state = (buffer_control == 1) ? S_WRITE : S_READ;
			S_WRITE:	next_state = (curr_waddr == write_end_addr) ? S_END : S_READ;
			S_END:		next_state = S_END;
	end

	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	///////// Registers
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//curr_radder register
	always_ff @(posedge clk_i) begin
		if (current_state == S_IDLE) begin
			curr_raddr <= read_start_addr;
			
		end else if (current_state == S_READ) begin
			curr_raddr <= curr_raddr + 1; 	//moves address forward
		end
	end 

	//curr_wadder register
	always_ff @(posedge clk_i) begin
		if(current_state == S_IDLE) begin	
			curr_waddr <= write_start_addr;
		end
	end

	//buffer control register
	always_ff @(posedge clk_i) begin
		buffer_control <= 0;
			if (current_state == S_ADD) begin
				buffer_control <= ~buff_control;
		end
	end

	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//// comb blocks
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	assign r_addr = curr_raddr;
	assign w_addr = curr_waddr;
	assign read = 1;
	assign write = 1;
	assign w_data = buffer_o;
	assign current_state = next_state;

	always_comb begin
		if (current_state == S_add)begin
				op_a = [DATA_W-1:32]r_data;						//assgines the data from the address to the adder input a
				op_b = [31:0]		r_data; 					//assgines the data from the address to the adder input b
		end
	end
	
	//read enable
	always_comb begin
        read = ~(state == S_READ);		//when current_state == S_READ it sets it to 0 which enables reading
    end

    // Write enable
    always_comb begin
        write = ~(state == S_WRITE);	//when current_state == S_WRITE it sets it to 0 which enables writing
    end

	//Next_state current_state logic, outputs

endmodule
