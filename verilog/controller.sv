module controller import calculator_pkg::*;(
  	input  logic              clk_i,
    input  logic              rst_i,
  
  	// Memory Access
    input  logic [ADDR_W-1:0] read_start_addr,
    input  logic [ADDR_W-1:0] read_end_addr,
    input  logic [ADDR_W-1:0] write_start_addr,
    input  logic [ADDR_W-1:0] write_end_addr,
  
  	// Control
    output logic write,
    output logic [ADDR_W-1:0] w_addr,
    output logic [MEM_WORD_SIZE-1:0] w_data,

    output logic read,
    output logic [ADDR_W-1:0] r_addr,
    input  logic [MEM_WORD_SIZE-1:0] r_data,

  	// Buffer Control (1 = upper, 0, = lower)
    output logic              buffer_control,
  
  	// These go into adder
  	output logic [DATA_W-1:0]       op_a,
    output logic [DATA_W-1:0]       op_b,
  
    input  logic [MEM_WORD_SIZE-1:0]       buff_result
  
); 
	//TODO: Write your controller state machine as you see fit. 
	//HINT: See "6.2 Two Always BLock FSM coding style" from refmaterials/1_fsm_in_systemVerilog.pdf
	// This serves as a good starting point, but you might find it more intuitive to add more than two always blocks.

	typedef enum logic [2:0] {S_IDLE,S_READ,S_ADD,S_WRITE,S_END} state_t;
  	state_t state, next;

	//State reg, other registers as needed
	always_ff @(posedge clk_i) begin
		if (rst_i)
			state <= S_IDLE;
		else
			state <= next;
	end
	
	//Next state logic, outputs
	always_comb begin
		case (state)
			S_IDLE: begin
				if()
					next = S_READ;
				else 
					state = S_IDLE;
			end
			S_READ: begin //pull 32 bits from both SRAM A and B. 
				read = 1
				r
			end
			S_ADD:  begin 

			end
			S_WRITE:begin 
				if buffer_control = 1
					//write to upper
				else
				//write to lower and 
				state = S_end
			end
			S_END: begin 

			end
		endcase
	end

endmodule
