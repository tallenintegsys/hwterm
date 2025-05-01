//////////////////////////////////////////////////////////////////////
// Based on file Downloaded from http://www.nandland.com
//////////////////////////////////////////////////////////////////////
// This file contains the UART Transmitter. This transmitter is N,8,1
// When tx is complete o_Tx_done will be driven high for _one_ clock
// period.
//
// Set Parameter CLKS_PER_BIT as follows:
// CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
// Example: 25 MHz Clock, 115200 baud UART: (25000000)/(115200) = 217
`ifndef UART_TX_H
`define UART_TX_H

module uart_tx #(parameter CLKS_PER_BIT = 217) (
    input       i_Clock,
    input       i_TX_DV,
    input [7:0] i_TX_Byte,
    output      o_TX_Active,
    output reg  o_TX_Serial,
    output      o_TX_Done);

localparam IDLE         = 3'b000;
localparam TX_START_BIT = 3'b001;
localparam TX_DATA_BITS = 3'b010;
localparam TX_STOP_BIT  = 3'b011;
localparam CLEANUP      = 3'b100;

reg [2:0]   r_SM_Main       = 0;
reg [15:0]  r_Clock_Count   = 0;
reg [2:0]   r_Bit_Index     = 0;
reg [7:0]   r_TX_Data       = 0;
reg         r_TX_Done       = 0;
reg         r_TX_Active     = 0;

always @(posedge i_Clock) begin // Purpose: Control TX state machine
    case (r_SM_Main)
    IDLE : begin    // Wait for DV
            o_TX_Serial <= 1'b1; // Drive Line High for Idle
            r_TX_Done <= 1'b0; // only stays high for one clock
            r_Clock_Count <= 0;
            r_Bit_Index <= 0;
            if (i_TX_DV == 1'b1) begin
                r_TX_Active <= 1'b1;
                r_TX_Data <= i_TX_Byte; // latch the incomming byte
                r_SM_Main <= TX_START_BIT;
            end else
                r_SM_Main <= IDLE;
    end // case: IDLE
    TX_START_BIT : begin    // Send out Start Bit.
        o_TX_Serial <= 1'b0;    // Start bit = 0
        if (r_Clock_Count < CLKS_PER_BIT-1) begin   // Wait CLKS_PER_BIT-1 clocks for start bit to finish
            r_Clock_Count <= r_Clock_Count + 16'd1;
            r_SM_Main <= TX_START_BIT;
        end else begin
            r_Clock_Count <= 0;
            r_SM_Main <= TX_DATA_BITS;
        end
    end // case: TX_START_BIT
    TX_DATA_BITS : begin    // each bit lasts CLKS_PER_BIT clocks
        o_TX_Serial <= r_TX_Data[r_Bit_Index];
        if (r_Clock_Count < CLKS_PER_BIT-1) begin
            r_Clock_Count <= r_Clock_Count + 16'd1;
            r_SM_Main <= TX_DATA_BITS;
        end else begin
            r_Clock_Count <= 0;
            if (r_Bit_Index < 7) begin  // Check if we have sent out all bits
                r_Bit_Index <= r_Bit_Index + 3'd1;
                r_SM_Main <= TX_DATA_BITS;
            end else begin
                r_Bit_Index <= 0;
                r_SM_Main <= TX_STOP_BIT;
            end
        end
    end // case: TX_DATA_BITS
    TX_STOP_BIT : begin // Send out Stop bit.
        o_TX_Serial <= 1'b1;    // Stop bit = 1
        if (r_Clock_Count < CLKS_PER_BIT-1) begin // Wait CLKS_PER_BIT-1 clocks for Stop bit to finish
            r_Clock_Count <= r_Clock_Count + 16'd1;
            r_SM_Main <= TX_STOP_BIT;
        end else begin
            r_Clock_Count <= 0;
            r_SM_Main <= CLEANUP;
            r_TX_Active <= 1'b0;
        end
    end // case: TX_STOP_BIT
    CLEANUP : begin // Stay here CLKS_PER_BIT clocks
        if (r_Clock_Count < CLKS_PER_BIT-1) begin   // Wait CLKS_PER_BIT-1 clocks
            r_Clock_Count <= r_Clock_Count + 16'd1;
		end else begin
			r_TX_Done <= 1'b1;
            r_Clock_Count <= 0;
			r_SM_Main <= IDLE;
		end
    end // case CLEANUP
    default :
        r_SM_Main <= IDLE;
    endcase
end // always

assign o_TX_Active = r_TX_Active;
assign o_TX_Done = r_TX_Done;

endmodule
`endif // UART_TX_H
