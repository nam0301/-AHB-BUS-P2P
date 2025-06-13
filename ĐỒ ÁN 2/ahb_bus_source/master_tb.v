`timescale 1ns/1ps

module tb_ahb_master;

    reg         HCLK;
    reg         HRESETn;
    wire [31:0] HADDR;
    wire [31:0] HWDATA;
    reg  [31:0] HRDATA;
    wire        HWRITE;
    wire [1:0]  HTRANS;
    reg         HREADY;

    // Instantiate DUT
    ahb_master dut (
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .HADDR(HADDR),
        .HWDATA(HWDATA),
        .HRDATA(HRDATA),
        .HWRITE(HWRITE),
        .HTRANS(HTRANS),
        .HREADY(HREADY)
    );

    // Clock generation
    initial HCLK = 0;
    always #5 HCLK = ~HCLK; // 100 MHz clock

    // Reset sequence
    initial begin
        HRESETn = 0;
        HREADY  = 1;
        HRDATA  = 32'h0;
        #20;
        HRESETn = 1;
    end

    // Test procedure
    initial begin
        @(posedge HRESETn);
        @(posedge HCLK);

        // Test GHI
        $display("Starting WRITE transaction...");
        force dut.write_addr = 32'h00000010;
        force dut.write_data = 32'hDEADBEEF;
        force dut.start_write = 1;

        @(posedge HCLK);
        force dut.start_write = 0;
        @(posedge HCLK);

        // Đợi giao dịch ghi hoàn tất
        repeat(2) @(posedge HCLK);

        // Test ĐỌC
        $display("Starting READ transaction...");
        force dut.read_addr = 32'h00000010;
        force dut.start_read = 1;

        @(posedge HCLK);
        force dut.start_read = 0;
        HRDATA = 32'hDEADBEEF;

        // Đợi dữ liệu đọc hoàn tất
        repeat(2) @(posedge HCLK);

        $display("Read data = %h", dut.read_data);

        $finish;
    end

endmodule
