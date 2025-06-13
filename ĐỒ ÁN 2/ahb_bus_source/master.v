`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/19/2025 12:01:20 PM
// Design Name: 
// Module Name: master
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ahb_master (
    input wire HCLK,
    input wire HRESETn,
    output reg [31:0] HADDR,
    output reg [31:0] HWDATA,
    input wire [31:0] HRDATA,
    output reg HWRITE,
    output reg [1:0] HTRANS,
    input wire HREADY
);

    // State encoding
    parameter IDLE = 2'b00, WRITE = 2'b01, READ = 2'b10;
    reg [1:0] state;
    
    reg [31:0] write_addr, write_data;
    reg [31:0] read_addr;
    reg [31:0] read_data;  // Lưu dữ liệu đọc được

    reg start_write, start_read; // Tín hiệu khởi động giao dịch

    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            HADDR   <= 32'h0;
            HWDATA  <= 32'h0;
            HWRITE  <= 1'b0;
            HTRANS  <= 2'b00;  // IDLE
            state   <= IDLE;
            start_write <= 1'b0;
            start_read  <= 1'b0;
        end else if (HREADY) begin
            case (state)
                IDLE: begin
                    if (start_write) begin
                        // Bắt đầu giao dịch ghi
                        HADDR  <= write_addr;   // từ tb
                        HWDATA <= write_data; //từ tb
                        HWRITE <= 1'b1;    // Ghi dữ liệu
                        HTRANS <= 2'b10;   // NONSEQ (Giao dịch không tuần tự)
                        state  <= WRITE;
                    end else if (start_read) begin
                        // Bắt đầu giao dịch đọc
                        HADDR  <= read_addr; // từ tb
                        HWRITE <= 1'b0;   // Đọc dữ liệu
                        HTRANS <= 2'b10;  // NONSEQ
                        state  <= READ;
                    end
                end

                WRITE: begin
                    // Kết thúc ghi, quay về IDLE
                    HTRANS <= 2'b00; // Trạng thái IDLE
                    state  <= IDLE;
                    start_write <= 1'b0;
                end

                READ: begin
                    // Nhận dữ liệu đọc được từ HRDATA
                    read_data <= HRDATA;
                    HTRANS <= 2'b00; // Trạng thái IDLE
                    state  <= IDLE;
                    start_read <= 1'b0;
                end
            endcase
        end
    end

    // Task để khởi động ghi
    task start_write_transaction(input [31:0] addr, input [31:0] data);
        begin
            write_addr <= addr;
            write_data <= data;
            start_write <= 1'b1;
        end
    endtask

    // Task để khởi động đọc
    task start_read_transaction(input [31:0] addr);
        begin
            read_addr <= addr;
            start_read <= 1'b1;
        end
    endtask

endmodule

