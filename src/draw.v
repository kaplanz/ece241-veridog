//
//  draw.v
//  Draw an image from ROM
//
//  Created by Zakhary Kaplan on 2019-11-12.
//  Copyright © 2019 Zakhary Kaplan. All rights reserved.
//

module draw #(
    parameter   X_WIDTH = 8,
                Y_WIDTH = 7) (

    input resetn,
    input clk,
    input start,
    input [X_WIDTH-1:0] xInit,
    input [Y_WIDTH-1:0] yInit,

    output [X_WIDTH-1:0] xOut,
    output [Y_WIDTH-1:0] yOut,
    output reg [7:0] colour,
    output reg writeEn,
    output reg done
    );

    parameter   X_MAX   = 160,
                Y_MAX   = 120;


    // state registers
    reg [1:0] currentState, nextState;

    localparam  IDLE    = 2'h0,
                LOAD    = 2'h1,
                WRITE   = 2'h2,
                DONE    = 2'h3;


    // drawing state table
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


    // iterators
    reg [X_WIDTH-1:0] x;
    reg [Y_WIDTH-1:0] y;

    // output coordinates
    assign xOut = xInit + x;
    assign yOut = yInit + y;

    // perform state functions
    always @(*)
    begin: stateFunctions
        case (currentState)
            IDLE: begin
                x = {X_WIDTH{1'b0}};
                y = {X_WIDTH{1'b0}};
                colour = 8'b0;
                writeEn = 1'b0;
                done = 1'b0;
            end
            LOAD: begin
                x++;
                if (x == X_MAX) begin
                    x = {X_WIDTH{1'b0}};
                    y++;

                    if (y == Y_MAX) begin
                        done = 1'b1;
                    end
                end
                colour = 8'b0; // FIXME
            end
            WRITE: writeEn = 1'b1;
            DONE: done = 1'b1;
        endcase
    end // stateFunctions


    // update state registers
    always @(posedge clk)
    begin: stateFFs
        if (!resetn)
            currentState <= IDLE;
        else
            currentState <= nextState;
    end // stateFFs
endmodule
