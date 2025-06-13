`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/19/2025 12:00:54 PM
// Design Name: 
// Module Name: slave
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


module ahb_slave (
    input wire HCLK,
    input wire HRESETn,
    input wire [31:0] HADDR,
    input wire [31:0] HWDATA,
    output reg [31:0] HRDATA,
    input wire HWRITE,
    input wire [1:0] HTRANS,
    input wire HREADY
);
    // Bộ nhớ 256 từ (word), mỗi từ 32-bit
    reg [31:0] mem [0:255];

    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            HRDATA <= 32'h0;
        end else if (HREADY && HTRANS[1]) begin
            if (HWRITE) begin
                // Ghi dữ liệu vào bộ nhớ
                mem[HADDR[7:0] >> 2] <= HWDATA;
            end else begin
                // Đọc dữ liệu từ bộ nhớ
                HRDATA <= mem[HADDR[7:0] >> 2];
            end
        end
    end
endmodule