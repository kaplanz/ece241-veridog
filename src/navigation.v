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

    // Declare state values
    localparam  ROOT        = 9'b0'h00,
                LOAD_HOME   = 9'b1'h10,
                LOAD_ARCADE = 9'b1'h20,

                HOME        = 9'b0'h10,

                ARCADE      = 9'b0'h20;

    // State register
    reg [8:0] currentState;

    // Assign outputs
    assign transition = currentState[8]; // transition occurs during wait states
    assign location = currentState[7:4]; // left hex digit encodes location
    assign activity = currentState[3:0]; // right hex digit encodes activity

    // Update state registers, perform incremental logic
    always @(posedge clk)
    begin: stateFFs
        if (!resetn)
            currentState <= ROOT;
        else begin
            case (currentState)
                ROOT: begin // choose next location
                    case (keys)
                        3'b100: currentState = LOAD_HOME;
                        3'b001: currentState = LOAD_ARCADE;
                        default: currentState = ROOT;
                    endcase
                end

                // Stay in load state until keys released, load background
                LOAD_HOME:
                    currentState = (keys == 3'b0) ? HOME : LOAD_HOME;
                HOME: begin // choose activity
                    case (keys)
                        default: currentState = HOME;
                    endcase
                end

                // Stay in load state until keys released, load background
                LOAD_ARCADE:
                    currentState = (keys == 3'b0) ? ARCADE : LOAD_ARCADE;
                ARCADE: begin // choose activity
                    case (keys)
                        default: currentState = ARCADE;
                    endcase
                end

                // Default to ROOT state
                default:
                    currentState = ROOT;
            endcase
        end
    end // stateFFs
endmodule
