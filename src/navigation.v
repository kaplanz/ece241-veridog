//
//  navigation.v
//  Navigation FSM
//
//  Created by Zakhary Kaplan on 2019-11-10.
//  Copyright © 2019 Zakhary Kaplan. All rights reserved.
//

module navigation(
    input resetn,
    input clk,
    input [2:0] keys,
    input doneAction,
    input gameEnd,

    output transition,
    output [3:0] location, action
    );

    // Declare state values
    localparam  ROOT        = {1'b0, 8'h00},

                GO_HOME     = {1'b1, 8'h10},
                HOME        = {1'b0, 8'h10},
                DO_EAT      = {1'b1, 8'h11},
                EAT         = {1'b0, 8'h11},
                DO_SLEEP    = {1'b1, 8'h12},
                SLEEP       = {1'b0, 8'h12},

                GO_ARCADE   = {1'b1, 8'h20},
                ARCADE      = {1'b0, 8'h20},

                DO_GAME     = {1'b1, 8'h30},
                GAME        = {1'b0, 8'h33},

                END         = {1'b1, 8'hFF};

    // State register
    reg [8:0] currentState;

    // Assign outputs
    assign transition = currentState[8]; // transition occurs during wait states
    assign location = currentState[7:4]; // left hex digit encodes location
    assign action = currentState[3:0]; // right hex digit encodes action

    // Update state registers, perform incremental logic
    always @(posedge clk)
    begin: stateFFs
        if (!resetn)
            currentState <= ROOT;
        else if (gameEnd)
            currentState <= END;
        else begin
            case (currentState)
                ROOT: begin // choose next location
                    case (keys)
                        3'b001: currentState = GO_HOME;
                        default: currentState = ROOT;
                    endcase
                end

                // Stay in load state until keys released, load background
                GO_HOME: currentState = (keys == 3'b0) ? HOME : GO_HOME;
                HOME: begin // choose action
                    case (keys)
                        3'b100: currentState = DO_EAT;
                        3'b010: currentState = DO_SLEEP;
                        3'b001: currentState = GO_ARCADE;
                        default: currentState = HOME;
                    endcase
                end
                // Home actions
                DO_EAT: currentState <= (keys == 3'b0) ? EAT : DO_EAT;
                EAT: currentState <= (doneAction) ? GO_HOME : EAT;
                DO_SLEEP: currentState <= (keys == 3'b0) ? SLEEP : DO_SLEEP;
                SLEEP: currentState <= (doneAction) ? GO_HOME : SLEEP;

                // Stay in load state until keys released, load background
                GO_ARCADE: currentState = (keys == 3'b0) ? ARCADE : GO_ARCADE;
                ARCADE: begin // choose action
                    case (keys)
                        3'b100: currentState = DO_GAME;
                        3'b001: currentState = GO_HOME;
                        default: currentState = ARCADE;
                    endcase
                end
                // Game actions
                DO_GAME: currentState <= (keys == 3'b0) ? GAME : DO_GAME;
                GAME: currentState <= (doneAction) ? GO_ARCADE : GAME;

                // Default to ROOT state
                default: currentState = ROOT;
            endcase
        end
    end // stateFFs
endmodule
