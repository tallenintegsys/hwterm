//////////////////////////////////////////////////////////////////////
// File Downloaded from http://www.nandland.com
//////////////////////////////////////////////////////////////////////
// This file contains the UART Receiver. This receiver is able to receive 8 bits of serial data, one start bit,
// one stop bit, and no parity bit. When RX is complete o_RX_DV will be driven high for _one_ clock cycle.
//
// Set Parameter CLKS_PER_BIT as follows:
// CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
// Example: 10 MHz Clock, 115200 baud UART: (10000000)/(115200) = 87
`ifndef UART_RX_H
`define UART_RX_H

module uart_rx #(parameter CLKS_PER_BIT = 87) (
    input           i_Clock,
    input           i_RX_Serial,
    output          o_RX_DV,
    output [7:0]    o_RX_Byte);

parameter s_IDLE             = 3'b000;
parameter s_RX_START_BIT     = 3'b001;
parameter s_RX_DATA_BITS     = 3'b010;
parameter s_RX_STOP_BIT      = 3'b011;
parameter s_CLEANUP          = 3'b100;

reg r_RX_Data_R = 1'b1;
reg r_RX_Data   = 1'b1;

reg [7:0]   r_Clock_Count   = 0; //XXX make bigger for fast clocks
reg [2:0]   r_Bit_Index     = 0; //8 bits total
reg [7:0]   r_RX_Byte       = 0;
reg         r_RX_DV         = 0;
reg [2:0]   r_SM_Main       = 0; // IDLE

// Purpose: Double-register the incoming data. This allows it to be used in the UART RX Clock Domain.
always @(posedge i_Clock) begin // (It removes problems caused by metastability)
      r_RX_Data_R <= i_RX_Serial;
      r_RX_Data <= r_RX_Data_R;
end

always @(posedge i_Clock) begin // Purpose: Control RX state machine
    case (r_SM_Main)
    s_IDLE : begin  // Wait for start bit
        r_RX_DV <= 1'b0;
        r_Clock_Count <= 0;
        r_Bit_Index <= 0;
        if (r_RX_Data == 1'b0)               // Start bit detected
            r_SM_Main <= s_RX_START_BIT;
        else
            r_SM_Main <= s_IDLE;
    end // case: r_SM_Main
    s_RX_START_BIT : begin  // Check middle of start bit, make sure it's still low
        if (r_Clock_Count == (CLKS_PER_BIT-1)/2) begin
            if (r_RX_Data == 1'b0) begin
                r_Clock_Count <= 0;   // reset counter, found the middle
                r_SM_Main <= s_RX_DATA_BITS;
            end else
                r_SM_Main <= s_IDLE;
        end else begin
            r_Clock_Count <= r_Clock_Count + 1;
            r_SM_Main <= s_RX_START_BIT;
        end
    end // case: s_RX_START_BIT
    s_RX_DATA_BITS : begin  // Wait CLKS_PER_BIT-1 clock cycles to sample serial data
        if (r_Clock_Count < CLKS_PER_BIT-1) begin
            r_Clock_Count <= r_Clock_Count + 1;
            r_SM_Main <= s_RX_DATA_BITS;
        end else begin
            r_Clock_Count <= 0;
            r_RX_Byte[r_Bit_Index] <= r_RX_Data;
            if (r_Bit_Index < 7) begin  // Check if we have received all bits
                r_Bit_Index <= r_Bit_Index + 1;
                r_SM_Main <= s_RX_DATA_BITS;
            end else begin
                r_Bit_Index <= 0;
                r_SM_Main <= s_RX_STOP_BIT;
            end
        end
    end // case: s_RX_DATA_BITS
    s_RX_STOP_BIT : begin   // Receive Stop bit.   Stop bit = 1
        if (r_Clock_Count < CLKS_PER_BIT-1) begin   // Wait CLKS_PER_BIT-1 clock cycles for Stop bit to finish
            r_Clock_Count <= r_Clock_Count + 1;
            r_SM_Main <= s_RX_STOP_BIT;
    end else begin  // FIXME Tim are we actually checking for a stop bit or just waiting it out?
            r_RX_DV <= 1'b1;
            r_Clock_Count <= 0;
            r_SM_Main <= s_CLEANUP;
        end
    end // case: s_RX_STOP_BIT
    s_CLEANUP : begin   // Stay here 1 clock
        r_SM_Main <= s_IDLE;
        r_RX_DV    <= 1'b0;
    end // case: s_CLEANUP
    default :
        r_SM_Main <= s_IDLE;
    endcase
end // always

assign o_RX_DV   = r_RX_DV;
assign o_RX_Byte = r_RX_Byte;

endmodule // uart_rx
`endif // UART_TX_H
