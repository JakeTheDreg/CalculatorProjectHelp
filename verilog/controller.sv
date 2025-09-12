/*
* this contoller module controlls the flow of the FSM giving instructions based on the state the machine is in. 
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
	
	input  logic [MEM_WORD_SIZE-1:0] buff_result,// the result thats being stored in the buffer and will be written to SRAM
    output logic              buffer_control,	 // Buffer Control (1 = upper, 0, = lower)

  	output logic [DATA_W-1:0]       op_a,		//input into adder
    output logic [DATA_W-1:0]       op_b		//input into adder
); 

	//TODO: Write your controller state machine as you see fit. 
	//HINT: See "6.2 Two Always BLock FSM coding style" from refmaterials/1_fsm_in_systemVerilog.pdf
	// This serves as a good starting point, but you might find it more intuitive to add more than two always blocks.

	typedef enum logic [2:0] {S_IDLE,S_READ,S_ADD,S_WRITE,S_END} state_t;
  	state_t state, next;
	logic [ADDR_W-1:0] curr_raddr;				//internal counter
	logic [ADDR_W-1:0] curr_waddr;				//internal counter
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	///////////// State Machine
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	always_ff @(posedge clk_i) begin
		if (rst_i) begin
			state <= S_IDLE;
		end else begin
			state = next;
		end
	end

	always_comb begin
		case (state)
			S_IDLE:		next = S_READ;
			S_READ:		next = S_ADD;
			S_ADD:		next = (buffer_control == 1) ? S_WRITE : S_READ;
			S_WRITE:	next = (curr_waddr == write_end_addr) ? S_END : S_READ;
			S_END:		next = S_END;
		endcase
	end

	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	///////// Registers
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//curr_radder register
	always_ff @(posedge clk_i) begin
		if (state == S_IDLE) begin
			curr_raddr <= read_start_addr;
			
		end else if (state == S_READ) begin
			curr_raddr <= curr_raddr + 1; 	//moves address forward
		end
	end 

	//curr_wadder register
	always_ff @(posedge clk_i) begin
		if(state == S_IDLE) begin	
			curr_waddr <= write_start_addr;
		end
	end

	//buffer control register
	always_ff @(posedge clk_i) begin
		buffer_control <= 0;
			if (state == S_ADD) begin
				buffer_control <= ~buffer_control;
		end
	end

	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//// comb blocks
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	assign r_addr = curr_raddr;
	assign w_addr = curr_waddr;
	assign read = 1;
	assign write = 1;
	assign w_data = buff_result;
	assign state = next;

	always_comb begin
		if (state == S_ADD)begin
				op_a = r_data[DATA_W-1:32];						//assgines the data from the address to the adder input a
				op_b = r_data[31:0]; 					//assgines the data from the address to the adder input b
		end
	end
	
	//read enable
	always_comb begin
        read = ~(state == S_READ);		//when state == S_READ it sets it to 0 which enables reading
    end

    // Write enable
    always_comb begin
        write = ~(state == S_WRITE);	//when state == S_WRITE it sets it to 0 which enables writing
    end
endmodule
