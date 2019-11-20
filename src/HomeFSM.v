//
//  HomeFSM.v
//  HomeFSM
//
//  Created by Alex Lehner on 2019-11-15.
//  Copyright © 2019 Alex Lehner. All rights reserved.


module homeFSM(keys, resetn, leaveHome, clk, sleeping, eating, doneAction);
    input [2:0] keys;
    input clk;
    input resetn;
    output reg leaveHome = 1'b0;
    output reg sleeping, eating;

    reg [3:0] currentState;
    input doneAction;

    localparam EAT = 4'd0,
               SLEEP = 4'd1,
               IDLE = 4'd2,
               LEAVE = 4'd3,
               RESET = 4'd4;


    always@(posedge clk)
    begin: stateFFs
        if (!resetn) begin
                currentState <= RESET;
        end
        else  begin
            case (currentState)
                IDLE: begin
                    sleeping <= 1'b0;
                    eating <= 1'b0;
                    leaveHome <= 1'b0;
                     case({keys, resetn})
                        4'b0001: currentState <= RESET;
                        4'b0010: currentState <= LEAVE;
                        4'b0100: currentState <= SLEEP;
                        4'b1000: currentState <= EAT;
                         default: currentState <= IDLE;
                    endcase
                    end
                SLEEP: begin
                    sleeping <= 1'b1;
                    currentState= (doneAction == 1'b1) ? IDLE:SLEEP;
                end
                EAT: begin
                     eating <=1'b1;
                     currentState <= (doneAction == 1'b1) ? IDLE: EAT;
                 end
                LEAVE: begin
                    leaveHome <= 1'b1;
                    currentState <= IDLE;
                end
                RESET: begin
                    currentState <= IDLE;
                end

                default: currentState <= IDLE;

            endcase
        end
    end

endmodule
