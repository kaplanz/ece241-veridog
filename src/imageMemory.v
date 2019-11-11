//
//  imageMemory.v
//  Image memory buffers
//
//  Created by Zakhary Kaplan on 2019-11-11.
//  Copyright © 2019 Zakhary Kaplan. All rights reserved.
//

module locationMemory(
    input [4:0] location,
    output [7:0] image [6:0],
    );

    localparam  ROOT    = 4'h0,
                HOME    = 4'h1,
                ARCADE  = 4'h2;

    reg [7:0] black [6:0];
    reg [7:0] home [6:0];
    reg [7:0] arcade [6:0];

    initial begin
        $display("Loading images...");
        $readmemh("assets/black.mif", black);
        $readmemh("assets/home.mif", home);
        $readmemh("assets/arcade.mif", arcade);
    end

    always @(*)
    begin
        case (location)
            HOME: image = home;
            ARCADE: image = arcade;
            default: image = black;
        endcase
    end
endmodule
