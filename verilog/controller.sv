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
	logic [ADDR_W-1:0] curr_waddr,

    output logic read,
    output logic [ADDR_W-1:0] r_addr,
    input  logic [MEM_WORD_SIZE-1:0] r_data,
	logic [ADDR_W-1:0] curr_raddr,

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
		if (rst_i) begin
			state <= S_IDLE;
			curr_raddr <= read_start_addr;
			curr_waddr <= write_start_addr;
			op_a         <= '0;
    		op_b         <= '0;
			buffer_control <= 0;
		end

		if(state == S_IDLE) begin
			state <= next;
		end

		if (state == S_READ) begin
				r_addr <= curr_raddr; 			//sets what address to pull data from
				op_a <= r_data;					//assgines the data from the address to the adder input a
				op_b <= r_data; 				//assgines the data from the address to the adder input b
				curr_raddr <= curr_raddr + 1; 	//moves address forward
				state <= next;
		end

		if(state == S_ADD) begin
			buffer_control <= ~buff_result;		//toggles buffer location
			state <= next;
		end

		if(state == S_WRITE) begin
			w_addr <= curr_waddr;				//sets what address to write data to;
			curr_waddr <= curr_waddr + 1;		//moves address forward
			w_data <= buff_result;				//gets the data from the buffer to write in the SRAM
			state <= next;
		end
	
	end
	
	//Next state logic, outputs
	always_comb begin

		//defaut outputs to avoid latches
		read   = 0;
	  	r_addr = curr_raddr;
  		write  = 0;
	  	w_addr = curr_waddr;
  		w_data = buffer_o;  
	  	next   = state;

		case (state)
			//after one cycle moves to read
			S_IDLE: begin 
				next = S_READ;
			end

			S_READ: begin //asserts read signal and provides the address to memory
				read = 1; //tells it to read
				
				if(curr_raddr == read_end_addr)begin //stops from moving to next state untill all 32 bits are assigned.
					next = S_ADD;	//always exits to S_ADD
				end else 
					next = S_READ;	//continues if all 32 bits are not assigned.
			end

			S_ADD:  begin //The state is where the two operands are provided to the external adder module and the 32-bit result is stored in the result buffer; buffer writes to lower first then does S_READ and S_ADDER again, and then writes that to top then moves to S_WRITE
					if(buffer_control == 1)//filled the result buffer, transition to WRITE
						next = S_WRITE;
					else 
						next = S_READ; //if writing to the lower half, transition to READ
			end

			S_WRITE:begin //The state writes the calculated result back into memory. The controller asserts the write signal and provides the address and data.
				write = 1; //tells it to write
				
				if (curr_waddr == write_end_addr) begin//if it has not finished adding from the range of addresses, then it exits to READ
					next = S_END;
				end else begin
					next = S_READ;
				end				
			end

			S_END:	//nothing to be done, idle in state untill reset.	
		endcase
	end

endmodule
