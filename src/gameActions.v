//
//  gameActions.v
//  gameActions.
//
//  Created by Alex Lehner on 2019-11-25.
//  Copyright © 2019 Alex Lehner. All rights reserved.
//

module gameActions(
    input resetn,
    input clk,
    input doGame,
    input [2:0] keys,

    output reg [3:0] gameState,
    output reg [9:0] score,
    output redraw,
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
                RESULT  = 4'd6,
                WIN     = 4'd7,
                LOSE    = 4'd8,
                DONE    = 4'd9;


    // -- Internal signals --
    // State register
    reg [3:0] currentState;

    // Score register
    reg [9:0] scoreReg = 10'b11111; // start at halfway

    // Set duration of an action
    wire doneSpin;
    rateDivider ACTION_DURATION(
        .resetn(~doGame), // reset when not performing action
        .clk(clk),
        .out(doneSpin) // turns on when action is completed
    );
    defparam ACTION_DURATION.MAX = 150_000_000;

    wire [1:0] randIn;
    pseudoRand RANDOM(
        .resetn(resetn),
        .clk(clk),
        .out(randIn)
    );


    // -- Control --
    // Assign outputs
    assign redraw = (currentState == SPIN | currentState == RESULT | currentState == WIN | currentState == LOSE);
    assign done = (currentState == DONE);

    always @(*)
    begin: updateScore
        if (currentState == IDLE)
            score <= 10'b0;
        else
            score <= scoreReg;
    end // updateScore

    // Update state registers, perform incremental logic
    always@(posedge clk)
    begin: stateFFs
        if (!resetn) begin
            currentState <= IDLE;
            gameState <= IDLE;
            scoreReg <= 10'b11111;
        end
        else begin
            case (currentState)
                IDLE: begin
                    currentState <= (doGame) ? SPIN : IDLE;
                end

                SPIN: begin
                    if (~doneSpin) begin
                        currentState <= SPIN;
                        gameState <= SPIN;
                    end
                    else begin
                        case (randIn)
                            2'b00: currentState <= NUN;
                            2'b01: currentState <= GIMEL;
                            2'b10: currentState <= HAY;
                            2'b11: currentState <= SHIN;
                            default: currentState <= DONE;
                        endcase
                    end
                end

                NUN: begin // nun: nothing
                    currentState <= RESULT;
                    gameState <= NUN;
                end

                GIMEL: begin // gimel: gain 2
                    currentState <= RESULT;
                    gameState <= GIMEL;
                    scoreReg <= {score[7:0], 2'b11};
                end

                HAY: begin // hay: gain 1
                    currentState <= RESULT;
                    gameState <= HAY;
                    scoreReg <= {score[8:0], 1'b1};
                end

                SHIN: begin // shin: lose 2
                    currentState <= RESULT;
                    gameState <= SHIN;
                    scoreReg <= {2'b00, score[9:2]};
                end

                RESULT: begin
                    if (scoreReg == {10{1'b1}})
                        currentState <= WIN;
                    else if (scoreReg == 10'b0)
                        currentState <= LOSE;
                    case (keys)
                        3'b100: currentState <= SPIN;
                        3'b001: currentState <= DONE;
                    endcase
                end

                WIN: begin
                    currentState <= (keys != 3'b0) ? DONE : WIN;
                    gameState <= WIN;

                end

                LOSE: begin
                    currentState <= (keys != 3'b0) ? DONE : LOSE;
                    gameState <= LOSE;
                end

                DONE: begin
                    currentState <= (~doGame) ? IDLE : DONE;
                    scoreReg <= 10'b11111; // reset score after game ends
                end

                default:
                    currentState <= IDLE;
            endcase
        end
    end // stateFFs
endmodule
