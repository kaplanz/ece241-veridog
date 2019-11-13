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

    output transition,
    output [3:0] location, activity
    );

    // State registers
    reg [7:0] currentState, nextState;

    localparam  ROOT        = 8'h00,
                HOME        = 8'h01,
                ARCADE      = 8'h02,

                HOME_MENU   = 8'h10,
                EAT         = 8'h11,
                SLEEP       = 8'h12,

                ARCADE_MENU = 8'h20;


    // State table tree structure
    always @(*)
    begin: stateTable
        case (currentState)
            ROOT: begin // choose next location
                case (keys)
                    3'b100: nextState = HOME;
                    3'b001: nextState = ARCADE;
                    default: nextState = ROOT;
                endcase
            end

            // Wait until button is released for menu
            HOME: nextState = (keys == 3'b0) ? HOME_MENU : HOME;
            HOME_MENU: begin // choose activity
                case (keys)
                    3'b100: nextState = EAT;
                    3'b001: nextState = SLEEP;
                    default: nextState = HOME_MENU;
                endcase
            end

            // Wait until button is released for menu
            ARCADE: nextState = (keys == 3'b0) ? ARCADE_MENU : ARCADE;
            ARCADE_MENU: begin // choose activity
                case (keys)
                    default: nextState = ARCADE_MENU;
                endcase
            end

            // Default to ROOT state
            default: nextState = ROOT;
        endcase
    end // stateTable


    // Transition occurs whenever the next state is different from the current state
    assign transition = (nextState != currentState);
    // Left hexidecimal digit encodes location to draw
    assign location = currentState[7:4];
    // Right hexidecimal digit encodes activity
    assign activity = currentState[3:0];


    // Update state registers
    always @(posedge clk)
    begin: stateFFs
        if (!resetn)
            currentState <= ROOT;
        else
            currentState <= nextState;
    end // stateFFs
endmodule
