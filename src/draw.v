//
//  draw.v
//  Draw an image from ROM
//
//  Created by Zakhary Kaplan on 2019-11-12.
//  Copyright © 2019 Zakhary Kaplan. All rights reserved.
//

module draw #(
    parameter   X_WIDTH = 8,
                Y_WIDTH = 7,
                X_MAX = 160,
                Y_MAX = 120) (

    input resetn,
    input clk,
    input start,
    input [X_WIDTH-1:0] xInit,
    input [Y_WIDTH-1:0] yInit,

    output [X_WIDTH-1:0] xOut,
    output [Y_WIDTH-1:0] yOut,
    output reg writeEn,
    output reg done
    );


    // State registers
    reg [1:0] currentState, nextState;

    localparam  IDLE    = 2'h0,
                LOAD    = 2'h1,
                WRITE   = 2'h2,
                DONE    = 2'h3;


    // Drawing state table
    always @(*)
    begin: stateTable
        case (currentState)
            IDLE: nextState = (start) ? LOAD: IDLE;
            LOAD: nextState = WRITE;
            WRITE: nextState = (~done) ? LOAD : DONE;
            DONE: nextState = (start) ? DONE : IDLE;
            default: nextState = IDLE;
        endcase
    end // stateTable


    // Iterators
    reg [X_WIDTH-1:0] x;
    reg [Y_WIDTH-1:0] y;

    // Output coordinates
    assign xOut = xInit + x;
    assign yOut = yInit + y;

    // Perform state functions
    always @(*)
    begin: stateFunctions
        case (currentState)
            LOAD: begin
                x = x + {{X_WIDTH-1{1'b0}}, 1'b1};
                if (x == X_MAX) begin
                    x = {X_WIDTH{1'b0}};
                    y = y + {{Y_WIDTH-1{1'b0}}, 1'b1};

                    if (y == Y_MAX) begin
                        done = 1'b1;
                    end
                end
            end
            WRITE: writeEn = 1'b1;
            DONE: done = 1'b1;
            default: begin
                x = {X_WIDTH{1'b0}};
                y = {Y_WIDTH{1'b0}};
                writeEn = 1'b0;
                done = 1'b0;
            end
        endcase
    end // stateFunctions


    // Update state registers
    always @(posedge clk)
    begin: stateFFs
        if (!resetn)
            currentState <= IDLE;
        else
            currentState <= nextState;
    end // stateFFs
endmodule
