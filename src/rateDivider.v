//
//  rateDivider.v
//  Rate divider
//
//  Created by Alex Lehner on 2019-11-10.
//  Copyright © 2019 Alex Lehner. All rights reserved.
//

module rateDivider(input resetn, clk, output out);
    parameter   WIDTH   = 32,
                MAX     = 50_000_000;

    // -- Internal signals --
    // Counter register
    reg [WIDTH-1:0] counter = {WIDTH{1'b0}};

    // Assign output
    assign out = (counter == MAX);

    // Increment counter
    always @(posedge clk)
    begin: counterUpdate
        if (!resetn) begin
            counter <= {WIDTH{1'b0}}; // reset counter
        end
        else begin
            if (counter == MAX) begin
                counter <= {WIDTH{1'b0}}; // reset counter
            end
                else begin
                    counter <= counter + 1; // {{WIDTH-1{1'b0}}, 1'b1}; // increment counter
                end
        end
    end // counterUpdate
endmodule
