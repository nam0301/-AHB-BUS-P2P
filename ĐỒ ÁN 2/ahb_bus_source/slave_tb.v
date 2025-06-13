module ahb_tb;
    reg HCLK;
    reg HRESETn;
    wire [31:0] HADDR;
    wire [31:0] HWDATA;
    wire [31:0] HRDATA;
    wire HWRITE;
    wire [1:0] HTRANS;
    reg HREADY;

    ahb_master uut_master (
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .HADDR(HADDR),
        .HWDATA(HWDATA),
        .HRDATA(HRDATA),
        .HWRITE(HWRITE),
        .HTRANS(HTRANS),
        .HREADY(HREADY)
    );

    ahb_slave uut_slave (
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .HADDR(HADDR),
        .HWDATA(HWDATA),
        .HRDATA(HRDATA),
        .HWRITE(HWRITE),
        .HTRANS(HTRANS),
        .HREADY(HREADY)
    );

    initial begin
        HCLK = 0;
        forever #5 HCLK = ~HCLK;
    end

    initial begin
        HRESETn = 0;
        HREADY = 1;
        #10 HRESETn = 1;

        // === TEST CASE 1: Ghi 3 địa chỉ liên tiếp ===
        uut_master.start_write_transaction(32'h1000_0000, 32'hAAAA_BBBB);
        #20; // Đợi một chu kỳ trước khi gửi dữ liệu tiếp theo
        uut_master.start_write_transaction(32'h1000_0004, 32'hCCCC_DDDD);
        #20;
        uut_master.start_write_transaction(32'h1000_0008, 32'hEEEE_FFFF);
        #20;

        // Đọc lại 3 địa chỉ
        uut_master.start_read_transaction(32'h1000_0000);
        #20;
        uut_master.start_read_transaction(32'h1000_0004);
        #20;
        uut_master.start_read_transaction(32'h1000_0008);
        #20;

        // === TEST CASE 2: Ghi và đọc ngẫu nhiên ===
        uut_master.start_write_transaction(32'h2000_0000, 32'h1234_5678);
        #20;
        uut_master.start_write_transaction(32'h2000_0010, 32'h8765_4321);
        #20;
        uut_master.start_write_transaction(32'h2000_0020, 32'hDEAD_BEEF);
        #20;

        // Đọc lại dữ liệu
        uut_master.start_read_transaction(32'h2000_0000);
        #20;
        uut_master.start_read_transaction(32'h2000_0010);
        #20;
        uut_master.start_read_transaction(32'h2000_0020);
        #20;

        // === TEST CASE 3: Thử ghi đè dữ liệu ===
        uut_master.start_write_transaction(32'h1000_0004, 32'h5555_5555);
        #20;
        uut_master.start_write_transaction(32'h2000_0010, 32'h9999_9999);
        #20;

        // Đọc lại để kiểm tra ghi đè
        uut_master.start_read_transaction(32'h1000_0004);
        #20;
        uut_master.start_read_transaction(32'h2000_0010);
        #20;
        
        // === TEST CASE 4: Ghi vào địa chỉ hợp lệ ===
        uut_master.start_write_transaction(32'h1000_0000, 32'hAAAA_BBBB);
        #20;
        uut_master.start_read_transaction(32'h1000_0000);
        #20;

        // === TEST CASE 5: Ghi vào địa chỉ không hợp lệ ===
        uut_master.start_write_transaction(32'hFFDF_FDFF, 32'h1234_5678); // Địa chỉ không hợp lệ
        #20;
        uut_master.start_read_transaction(32'hFFDF_FFDF);
        #20;

        
                $display("\n=== TEST CASE 6: Giao dịch HTRANS = IDLE (không phản ứng) ===");
        uut_master.HTRANS <= 2'b00; // IDLE
        uut_master.HADDR  <= 32'h1000_0000;
        uut_master.HWRITE <= 1'b1;
        uut_master.HWDATA <= 32'hFFFFFFFF;
        #20;

        uut_master.start_read_transaction(32'h1000_0000); // Đọc lại -> không thấy thay đổi
        #20;

      

        $display("\n=== TEST CASE 8: Back-to-back write ===");
        uut_master.start_write_transaction(32'h4000_0000, 32'h1111_1111);
        uut_master.start_write_transaction(32'h4000_0004, 32'h2222_2222);
        uut_master.start_write_transaction(32'h4000_0008, 32'h3333_3333);
        #60;

        uut_master.start_read_transaction(32'h4000_0000);
        #20;
        uut_master.start_read_transaction(32'h4000_0004);
        #20;
        uut_master.start_read_transaction(32'h4000_0008);
        #20;

       

    end

    initial begin

    end
endmodule