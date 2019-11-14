//
//  draw.v
//  Draw an image from ROM
//
//  Created by Zakhary Kaplan on 2019-11-12.
//  Copyright © 2019 Zakhary Kaplan. All rights reserved.
//

module draw160x120(
    input resetn,
    input clk,
    input start,
    input [8:0] xInit,
    input [7:0] yInit,

    output [7:0] xOut,
    output [6:0] yOut,
    output [7:0] colour,
    output writeEn,
    output done
    );

    parameter IMAGE = "assets/black.mif";

    // Iterator
    wire [7:0] x;
    wire [6:0] y;
    iterator #(8, 7, 160, 120) ITERATOR(
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
        .address((160 * y) + x),
        .clock(clk),
        .q(colour));
    defparam ROM.init_file = IMAGE;
endmodule


module draw40x40(
    input resetn,
    input clk,
    input start,
    input [5:0] xInit,
    input [5:0] yInit,

    output [5:0] xOut,
    output [5:0] yOut,
    output [7:0] colour,
    output writeEn,
    output done
    );

    parameter IMAGE = "assets/black.mif";

    // Iterator
    wire [5:0] x;
    wire [5:0] y;
    iterator #(6, 6, 40, 40) ITERATOR(
        .resetn(resetn),
        .clk(clk),
        .start(start),
        .x(x),
        .y(y),
        .writeEn(writeEn),
        .done(done)
    );

    // Assign outputs
    assign xOut = (yInit + x);
    assign yOut = (xInit + y);

    // Image memory ROM for retrieving colour
    rom160x120 ROM(
        .address((40 * y) + x),
        .clock(clk),
        .q(colour));
    defparam ROM.init_file = IMAGE;
endmodule


module iterator #(
    parameter   X_WIDTH = 8,
                Y_WIDTH = 7,
                X_MAX = 160,
                Y_MAX = 120) (

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
                LOAD    = 2'h1,
                WRITE   = 2'h2,
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
                    if(x == X_MAX - 1) begin
                        x <= {X_WIDTH{1'b0}}; // reset x
                        y <= y + {{Y_WIDTH-1{1'b0}}, 1'b1}; // increment y
                    end
                    else begin
                        x <= x + {{X_WIDTH-1{1'b0}}, 1'b1}; // increment x
                    end

                    currentState <= WRITE;
                end

                DONE:
                    currentState <= (start) ? DONE : IDLE;

                default:
                    currentState <= IDLE;

            endcase
        end
    end // stateFFs
endmodule
