//
//  pseudoRand.v
//  Pseudo random counter.
//
//  Created by Alex Lehner on 2019-11-27.
//  Copyright © 2019 Alex Lehner. All rights reserved.
//

module pseudoRand(
    input resetn,
    input clk,

    output [1:0] out
    );

    // -- Internal signals --
    // Stat register
    reg [1:0] randCounter = 0;

    // Assign output
    assign out = randCounter;

    // Perform stat changes
    always @(posedge clk)
    begin
        if (!resetn) begin
            randCounter <= 0;
        end
        else begin
            if (randCounter == 4)
                randCounter <= 0;
            else
                randCounter <= randCounter + 1;
        end
    end
endmodule
