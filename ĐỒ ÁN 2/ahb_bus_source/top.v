`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/19/2025 11:59:47 AM
// Design Name: 
// Module Name: top
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


module top (
    input wire HCLK,
    input wire HRESETn,
    // Bus signals
    input wire [31:0] HADDR,
    input wire [1:0]  HTRANS,
    input wire        HWRITE,
    input wire [2:0]  HSIZE,
    input wire [31:0] HWDATA,
    input wire [31:0] HRDATA,
    input wire        HREADY,
    input wire [1:0]  HRESP,
    output wire [31:0] debug_data_out
);
    assign debug_data_out = HRDATA;
    
    // Instantiate AHB Master
    ahb_master master (
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .HADDR(HADDR),
        .HTRANS(HTRANS),
        .HWRITE(HWRITE),
        .HWDATA(HWDATA),
        .HRDATA(HRDATA),
        .HREADY(HREADY)

    );

    // Instantiate AHB Slave
    ahb_slave slave (
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .HADDR(HADDR),
        .HTRANS(HTRANS),
        .HWRITE(HWRITE),
        .HWDATA(HWDATA),
        .HRDATA(HRDATA),
        .HREADY(HREADY)
    );

endmodule