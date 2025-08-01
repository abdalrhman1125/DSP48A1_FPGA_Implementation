module pipeline_mux ( in , out , sel , clk , rst , ce  );

parameter RSTTYPE = "SYNC" ;
parameter WIDTH = 18 ;

input [WIDTH-1 : 0] in ;
input sel ; 
input clk ; 
input rst ; 
input ce  ;
output [WIDTH-1 : 0] out ; 

reg [WIDTH-1 :0] out_reg ; 

generate 
    if (RSTTYPE == "SYNC") begin
        always @(posedge clk ) begin
            if (rst) 
                out_reg <= 0 ;
            else if (ce) 
                out_reg <= in ;
        end
    end
    else if (RSTTYPE == "ASYNC") begin 
        always @(posedge clk or posedge rst ) begin
            if (rst) 
                out_reg <= 0 ;
            else if (ce) 
                out_reg <= in ;
        end
    end
endgenerate

assign out = (sel)? out_reg : in ; 

endmodule