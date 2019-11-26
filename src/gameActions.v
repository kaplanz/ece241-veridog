//
//  gameActions.v
//  gameActions
//
//  Created by Alex Lehner on 2019-11-25.
//  Copyright © 2019 Alex Lehner. All rights reserved.
//

module gameActions(
    input resetn,
    input clk,
    input doGame,
    input [1:0] randIn,

    output [3:0] gameState,
    output done
    );

    // -- Local parameters --
    // Actions
    localparam  IDLE    = 4'd0,
                SPIN    = 4'd1,
                NUN     = 4'd2,
                GIMEL   = 4'd3,
                HAY     = 4'd4,
                SHIN    = 4'd5,
                DONE    = 4'd6;


    // -- Internal wires --
    wire doingGame = ((currentState != IDLE) & (currentState != DONE));
    wire doneSpin;

    // Set duration of an action
    rateDivider ACTION_DURATION(
        .resetn(~doGame), // reset when not performing action
        .clk(clk),
        .enable(doneSpin), // turns on when action is completed
    );
    defparam ACTION_DURATION.MAX = 250_000_000;


    // -- Control --
    // State register
    reg [3:0] currentState;

    // Assign outputs
    assign gameState = currentState;
    assign done = (currentState == DONE);

    // Update state registers, perform incremental logic
    always@(posedge clk)
    begin: stateFFs
        if (!resetn) begin
            currentState <= IDLE;
        end
        else begin
            case (currentState)
                IDLE:
                    currentState <= (doGame) ? SPIN : IDLE;

                SPIN: begin
                    if (~doneSpin) begin
                        currentState <= SPIN;
                    end
                    else begin
                        case (randIn)
                            2'b00: currentState <= NUN;
                            2'b01: currentState <= GIMEL;
                            2'b10: currentState <= HAY;
                            2'b11: currentState <= SHIN;
                        endcase
                    end
                end

                NUN: begin
                    currentState <= DONE;
                end

                GIMEL: begin
                    currentState <= DONE;
                end

                HAY: begin
                    currentState <= DONE;
                end

                SHIN: begin
                    currentState <= DONE;
                end

                DONE:
                    currentState <= (~doGame) ? IDLE : DONE;

                default:
                    currentState <= IDLE;
            endcase
        end
    end // stateFFs
endmodule
