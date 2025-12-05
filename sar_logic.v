module sar_logic #(parameter N=8) 
  ( input clk,
    input rst,
    input start,
    input comp_out,
    output reg sample,
    output reg busy,
    output reg done,
  	output reg [N-1:0] sar_code);
	// assign each state to a 3 bit number
    localparam [2:0] S_IDLE   = 3'b000;
    localparam [2:0] S_SAMPLE = 3'b001;
    localparam [2:0] S_TRIAL  = 3'b010;
    localparam [2:0] S_DECIDE = 3'b011;
    localparam [2:0] S_DONE   = 3'b100;

    reg [2:0]   state, next_state;
    reg [N-1:0] trial_bit_pointer;

    // FSM State Register
    always @(posedge clk) begin
        if (rst) begin
            state <= S_IDLE;
        end else begin
            state <= next_state;
        end
    end

    // FSM Next-State Logic
    always @(*) begin
        next_state = state; 
        case (state)
            S_IDLE:   if (start) next_state = S_SAMPLE;
            S_SAMPLE: next_state = S_TRIAL;
            S_TRIAL:  next_state = S_DECIDE;
            S_DECIDE: if (trial_bit_pointer == 1) next_state = S_DONE;
                      else next_state = S_TRIAL;
            S_DONE:   next_state = S_IDLE;
            default:  next_state = S_IDLE;
        endcase
    end

  // Datapath Logic (synchronous rst)
    always @(posedge clk) begin
        if (rst) begin
            sar_code<=0;
            trial_bit_pointer<=0;
        end else begin
            case (state) 
                S_SAMPLE: begin
                    sar_code<=0;
                    trial_bit_pointer<=(1<<(N-1));
                end
              
                S_TRIAL: sar_code<=sar_code|trial_bit_pointer;
              
                S_DECIDE: begin
                    if (comp_out==0) begin
                        sar_code<= sar_code& ~trial_bit_pointer;
                    end
                    trial_bit_pointer <= trial_bit_pointer >> 1;
                end
                S_DONE: trial_bit_pointer <= 0;//not necessary, but did it anyway
            endcase
        end
    end
    // Output Logic
    always @(*) begin
        sample = (state == S_SAMPLE);
        done   = (state == S_DONE);
        busy   = (state == S_TRIAL) | (state == S_DECIDE) | (state == S_DONE);
    end

endmodule