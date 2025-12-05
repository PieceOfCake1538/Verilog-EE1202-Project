module sar_logic_tb;
    
    localparam N = 8;
    localparam CLK_PERIOD = 10;

    reg clk;
    reg rst;
    reg start;
    reg comp_out;
    wire sample;
    wire busy;
    wire done;
    wire [N-1:0] sar_code;

    reg [N-1:0] test_vector = 8'b10110001;

    integer i;   // ← ✔ MOVE HERE

    // Instantiate DUT
    sar_logic #(.N(N)) dut (.*);

    // generate clock
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk; 
    end

    initial begin
        $display("Simulation Started: Initializing inputs...");
        rst = 1;
        start = 0;
        comp_out = 0;

        #(CLK_PERIOD * 2);
        rst = 0;
        #(CLK_PERIOD);

        $display("Reset released.");

        start = 1;
        @(posedge clk);
        start = 0;

        wait (sample == 1);
        $display("Sample pulse detected. Begin Successive approximation");

        @(posedge clk);
        @(posedge clk);

        for (i = N - 1; i >= 0; i = i - 1) begin
            comp_out <= test_vector[i];
            $display("Comp %0d: %b", N-i, test_vector[i]);
            @(posedge clk);
            @(posedge clk);
        end
    end

    // Checking results
    initial begin
        wait (done == 1);
        @(posedge clk);
        @(posedge clk);

        $display("Final sar_code = %b", sar_code);
        $display("outputs: %b , %b , %b", sample, busy, done);

        if (sar_code == test_vector)
            $display("TEST PASSED!");
        else
            $display("TEST FAILED! Expected %b, got %b", test_vector, sar_code);

        $finish;
    end

    // VCD dump
    initial begin
        $dumpfile("sar_logic.vcd");
        $dumpvars(0, sar_logic_tb);
    end

endmodule
