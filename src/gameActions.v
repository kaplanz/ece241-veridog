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
    output [9:0] score,
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


    // -- Internal signals --
    // State register
    reg [3:0] currentState;

    // Score register
    reg [9:0] scoreReg = 10'b11111; // start at halfway

    // Wires
    wire doneSpin;

    // Set duration of an action
    rateDivider ACTION_DURATION(
        .resetn(~doGame), // reset when not performing action
        .clk(clk),
        .out(doneSpin) // turns on when action is completed
    );
    defparam ACTION_DURATION.MAX = 250_000_000;


    // -- Control --
    // Assign outputs
    assign score = scoreReg;
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
                IDLE: begin
                    currentState <= (doGame) ? SPIN : IDLE;
                    // scoreReg <= 10'b0; // reset score after game ends
                end

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

                NUN: begin // nun: nothing
                    currentState <= DONE;
                end

                GIMEL: begin // gimel: gain 2
                    currentState <= DONE;
                    scoreReg <= {score[7:0], 2'b11};
                end

                HAY: begin // hay: gain 1
                    currentState <= DONE;
                    scoreReg <= {score[8:0], 1'b1};
                end

                SHIN: begin // shin: lose 2
                    currentState <= DONE;
                    scoreReg <= {2'b00, score[9:2]};
                end

                DONE:
                    currentState <= (~doGame) ? IDLE : DONE;

                default:
                    currentState <= IDLE;
            endcase
        end
    end // stateFFs
endmodule
