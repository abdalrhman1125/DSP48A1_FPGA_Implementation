module DSP (
    input clk , CEA , CEB , CEC , CECARRYIN , CED , CEM , CEOPMODE , CEP   ,
    input RSTA , RSTB , RSTC , RSTCARRYIN , RSTD , RSTM , RSTOPMODE , RSTP ,
    input [17 : 0 ] A ,B ,BCIN  ,D  ,
    input [47 : 0] C ,
    input CARRYIN ,
    input [7:0] opmode ,
    input [47:0] PCIN ,
    output CARRYOUT , CARRYOUTF ,
    output [47 : 0]  P , PCOUT  ,
    output [35:0] M ,
    output [17:0] BCOUT 
) ;

parameter A0REG = 0 ; 
parameter A1REG = 1 ; 
parameter B0REG = 0 ;
parameter B1REG = 1 ;
parameter CREG  = 1 ; 
parameter DREG  = 1 ; 
parameter MREG  = 1 ; 
parameter PREG  = 1 ; 
parameter CARRYINREG  = 1 ; 
parameter CARRYOUTREG = 1 ; 
parameter OPMODEREG   = 1 ; 
parameter CARRYINSEL = "OPMODE5" ;
parameter B_INPUT = "DIRECT" ; 
parameter RSTTYPE = "SYNC" ;

wire [17:0] A0_reg , A1_reg ,B1_reg , B0_reg  , D_reg  ; 
wire [47 : 0 ] C_reg ;
wire [7:0] opmode_reg ;
wire [17:0] B1_in ; 
wire [17:0 ] pre_adder_out ;
wire [35:0] M_in , M_reg ; 
wire CARRYOUT_reg , CARRYIN_reg ;
reg [47:0] POST_ADDER_in0 , POST_ADDER_in1 ;
reg [48 : 0] P_in ;

pipeline_mux #(.RSTTYPE(RSTTYPE) , .WIDTH(18)) B0_REG (       
    .in(B)         ,
    .sel(B0REG)    , 
    .clk(clk)      , 
    .rst (RSTB)    , 
    .ce (CEB)      ,  
    .out (B0_reg)  
    ); 

pipeline_mux #(.RSTTYPE(RSTTYPE) , .WIDTH(18)) D_REG (
    .in(D)        ,
    .sel(DREG)    , 
    .clk(clk)     , 
    .rst (RSTD)   , 
    .ce (CED)     ,  
    .out (D_reg)  
    );

pipeline_mux #(.RSTTYPE(RSTTYPE) , .WIDTH(8)) OPMODE_REG (
    .in(opmode)        ,
    .sel(OPMODEREG)    , 
    .clk(clk)          , 
    .rst (RSTOPMODE)   , 
    .ce (CEOPMODE)     ,  
    .out (opmode_reg)  
    );

assign pre_adder_out = (opmode_reg[6])? (D_reg - B0_reg) : (D_reg + B0_reg) ;    //  Pre Adder/Subtracter selction 

assign B1_in = (opmode_reg[4])? pre_adder_out : B0_reg ;     // Mux selection based on opmode[4]

pipeline_mux #(.RSTTYPE(RSTTYPE) , .WIDTH(18)) B1_REG (
    .in(B1_in)    ,
    .sel(B1REG)   , 
    .clk(clk)     , 
    .rst (RSTB)   , 
    .ce (CEB)     ,  
    .out (B1_reg) 
    );

assign BCOUT = B1_reg ;   //  BCOUT output port 

pipeline_mux #(.RSTTYPE(RSTTYPE) , .WIDTH(18)) A0_REG (
    .in(A)        ,
    .sel(A0REG)   , 
    .clk(clk)     , 
    .rst (RSTA)   , 
    .ce (CEA)     ,  
    .out (A0_reg) 
    );

pipeline_mux #(.RSTTYPE(RSTTYPE) , .WIDTH(18)) A1_REG (
    .in(A0_reg)        ,
    .sel(A1REG)   , 
    .clk(clk)     , 
    .rst (RSTA)   , 
    .ce (CEA)     ,  
    .out (A1_reg) 
    );

assign M_in = (B1_reg * A1_reg) ;  // Multiplier output

pipeline_mux #(.RSTTYPE(RSTTYPE) , .WIDTH(36)) M_REG (
    .in(M_in)        ,
    .sel(MREG)       , 
    .clk(clk)        , 
    .rst (RSTM)      , 
    .ce (CEM)        ,  
    .out (M_reg)     
    );

assign M = M_reg ;   //    M output port 

pipeline_mux #(.RSTTYPE(RSTTYPE) , .WIDTH(48)) C_REG (
    .in(C)           ,
    .sel(CREG)       , 
    .clk(clk)        , 
    .rst (RSTC)      , 
    .ce (CEC)        ,  
    .out (C_reg)     
    );

generate 
    if (CARRYINSEL == "CARRYIN") begin 
        pipeline_mux #(.RSTTYPE(RSTTYPE) , .WIDTH(1)) CARRYIN_REG (
            .in(CARRYIN)           ,
            .sel(CARRYINREG)       , 
            .clk(clk)              , 
            .rst (RSTCARRYIN)      , 
            .ce (CECARRYIN)        ,  
            .out (CARRYIN_reg)     
            );
    end
    else if (CARRYINSEL == "OPMODE5") begin
        pipeline_mux #(.RSTTYPE(RSTTYPE) , .WIDTH(1)) CARRYIN_REG (
            .in(opmode_reg[5])     ,
            .sel(CARRYINREG)       , 
            .clk(clk)              , 
            .rst (RSTCARRYIN)      , 
            .ce (CECARRYIN)        ,  
            .out (CARRYIN_reg)     
            );
    end
endgenerate

always @(*) begin 
    case (opmode_reg [1:0])          //     X-Mux 
        2'b00 : POST_ADDER_in0 = 0 ; 
        2'b01 : POST_ADDER_in0 = {12'h000, M_reg} ;
        2'b10 : POST_ADDER_in0 = P ;
        2'b11 : POST_ADDER_in0 = {D_reg[11:0], A0_reg , B0_reg} ;
    endcase

    case (opmode_reg [3:2])        //      Z-Mux 
       2'b00 : POST_ADDER_in1 = 0 ; 
       2'b01 : POST_ADDER_in1 = PCIN ; 
       2'b10 : POST_ADDER_in1 = P ; 
       2'b11 : POST_ADDER_in1 = C_reg ;  
    endcase

    case (opmode_reg[7])          //       Post Adder/Subtracter selction  
        1'b0 : P_in = (POST_ADDER_in0 + POST_ADDER_in1 + CARRYIN_reg) ;
        1'b1 : P_in = (POST_ADDER_in1 - (POST_ADDER_in0 + CARRYIN_reg) );
    endcase 
end
 
pipeline_mux #(.RSTTYPE(RSTTYPE) , .WIDTH(1)) CARRYOUT_REG (
    .in(P_in[48])           ,
    .sel(CARRYOUTREG)       , 
    .clk(clk)               , 
    .rst (RSTCARRYIN)       , 
    .ce (CECARRYIN)         ,  
    .out (CARRYOUT)         
    ); 

assign CARRYOUTF = CARRYOUT ;   //     CARRYOUTF output port 

pipeline_mux #(.RSTTYPE(RSTTYPE) , .WIDTH(48)) P_REG (
    .in(P_in[47 : 0]) ,
    .sel(PREG)        , 
    .clk(clk)         , 
    .rst (RSTP)       , 
    .ce (CEP)         ,  
    .out (P)          
    ); 

assign PCOUT = P ;           //        PCOUT out port

endmodule