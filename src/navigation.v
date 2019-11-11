//
//  navigation.v
//  Navigation FSM
//
//  Created by Zakhary Kaplan on 2019-11-10.
//  Copyright © 2019 Zakhary Kaplan. All rights reserved.
//

module navigation(
    input clk,
    input resetn,
    input keys,

    output [4:0] location, activity
    );

    reg [8:0] currentState, nextState;

    // left hexidecimal digit encodes location to draw
    assign location = currentState[7:4];
    // right hexidecimal digit encodes activity
    assign activity = currentState[3:0];

    localparam  ROOT        = 8'h00,
                HOME        = 8'h01,
                ARCADE      = 8'h02,

                HOME_MENU   = 8'h10,
                EAT         = 8'h11,
                SLEEP       = 8'h12,

                ARCADE_MENU = 8'h20;

    // state table tree structure
    always @(*)
    begin: stateTable
        case (currentState)
            ROOT: // choose next location
                case (keys)
                    3'b100: nextState = HOME;
                    3'b001: nextState = ARCADE;
                    default: nextState = ROOT;
                endcase

            // wait until button is released for menu
            HOME: nextState = (keys) ? HOME_MENU : HOME;
            HOME_MENU: // choose activity
                case (keys)
                    3'b100: nextState = EAT;
                    3'b001: nextState = SLEEP;
                    default: HOME_MENU;
                endcase

            // wait until button is released for menu
            ARCADE: nextState = (keys) ? ARCADE_MENU : ARCADE;
            ARCADE_MENU: // choose activity
                case (keys)
                    default: ARCADE_MENU;
                endcase

            // default to ROOT state
            default: nextState = ROOT;
        endcase
    end // stateTable

    // update state registers
    always @(posedge clk)
    begin: stateFFs
        if (!resetn)
            currentState <= ROOT;
        else
            currentState <= nextState;
    end // stateFFs
endmodule
