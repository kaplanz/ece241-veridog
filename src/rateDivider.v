//
//  rateDivider.v
//  Rate divider
//
//  Created by Alex Lehner on 2019-11-10.
//  Copyright © 2019 Alex Lehner. All rights reserved.
//

module rateDivider(input clk, output reg enable);
    parameter   WIDTH   = 32,
                MAX     = 25_000_000;

    reg [WIDTH-1:0] counter = {WIDTH{1'b0}};

    always @(posedge clk)
    begin
        counter <= counter + {{WIDTH-1{1'b0}}, 1'b1};
        if (counter == MAX) begin
            counter <= 0;
            enable <= ~enable;
        end
    end
endmodule
