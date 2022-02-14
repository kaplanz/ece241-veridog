// File:        draw.v
// Author:      Zakhary Kaplan <https://zakhary.dev>
// Created:     25 Nov 2019
// SPDX-License-Identifier: NONE

module draw #(
    parameter   X_WIDTH = 8,
                Y_WIDTH = 7,
                X_MAX   = 160,
                Y_MAX   = 120,
                IMAGE   = "assets/black.mif"
    ) (
    input resetn,
    input clk,
    input start,
    input [7:0] xInit,
    input [6:0] yInit,

    output [7:0] xOut,
    output [6:0] yOut,
    output [7:0] colour,
    output writeEn,
    output done
    );


    // Iterator
    wire [X_WIDTH-1:0] x;
    wire [Y_WIDTH-1:0] y;
    iterator #(X_WIDTH, Y_WIDTH, X_MAX, Y_MAX) ITERATOR(
        .resetn(resetn),
        .clk(clk),
        .start(start),
        .x(x),
        .y(y),
        .writeEn(writeEn),
        .done(done)
    );

    // Assign outputs
    assign xOut = (xInit + x);
    assign yOut = (yInit + y);

    // Image memory ROM for retrieving colour
    rom160x120 ROM(
        .address((X_MAX * y) + x),
        .clock(clk),
        .q(colour));
    defparam ROM.init_file = IMAGE;
endmodule


module iterator #(
    parameter   X_WIDTH = 8,
                Y_WIDTH = 7,
                X_MAX   = 160,
                Y_MAX   = 120
    ) (
    input resetn,
    input clk,
    input start,

    output reg [X_WIDTH-1:0] x,
    output reg [Y_WIDTH-1:0] y,
    output writeEn,
    output done
    );

    // Declare state values
    localparam  IDLE    = 2'h0,
                WRITE   = 2'h1,
                LOAD    = 2'h2,
                DONE    = 2'h3;

    // State register
    reg [1:0] currentState;

    // Assign outputs
    assign writeEn = (currentState == WRITE);
    assign done = (y == Y_MAX);

    // Update state registers, perform incremental logic
    always @(posedge clk)
    begin: stateFFs
        if (!resetn) begin
            currentState <= IDLE;
        end
        else begin
            case (currentState)
                IDLE: begin
                    currentState <= (start) ? WRITE: IDLE;
                    x <= {X_WIDTH{1'b0}}; // reset x
                    y <= {Y_WIDTH{1'b0}}; // reset y
                end

                WRITE:
                    currentState <= (~done) ? LOAD : DONE;

                LOAD: begin
                    if (x == X_MAX - 1) begin
                        x <= {X_WIDTH{1'b0}}; // reset x
                        y <= y + {{Y_WIDTH-1{1'b0}}, 1'b1}; // increment y
                    end
                    else begin
                        x <= x + {{X_WIDTH-1{1'b0}}, 1'b1}; // increment x
                    end

                    currentState <= WRITE;
                end

                DONE:
                    currentState <= (~start) ? IDLE : DONE;

                default:
                    currentState <= IDLE;
            endcase
        end
    end // stateFFs
endmodule
