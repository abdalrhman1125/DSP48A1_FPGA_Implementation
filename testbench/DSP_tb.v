module DSP_tb () ; 
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

reg [17 : 0 ] A ,B ,D , BCIN ;
reg [47 :0] C ;
reg CARRYIN , clk , CEA , CEB , CEC , CECARRYIN , CED , CEM , CEOPMODE ,CEP , 
    RSTA , RSTB , RSTC , RSTCARRYIN , RSTD , RSTM , RSTOPMODE , RSTP ; 
reg [7:0] opmode ; 
reg [47:0] PCIN ; 
wire CARRYOUT , CARRYOUTF ;
wire [47 : 0] P , PCOUT ; 
wire [35:0] M ; 
wire [17:0] BCOUT ; 

DSP #(A0REG ,A1REG, B0REG ,B1REG , CREG , DREG , MREG , PREG , CARRYINREG ,CARRYOUTREG , OPMODEREG ,  // DUT instantiation 
CARRYINSEL , B_INPUT , RSTTYPE) DUT (clk , CEA , CEB , CEC , CECARRYIN , CED , CEM , CEOPMODE , CEP ,
RSTA , RSTB , RSTC , RSTCARRYIN , RSTD , RSTM , RSTOPMODE , RSTP ,A ,B ,BCIN  ,D  , C , CARRYIN , opmode, 
PCIN, CARRYOUT , CARRYOUTF, P , PCOUT  , M , BCOUT) ;

initial begin         // Clock generation 
    clk = 0; 
    forever begin
        #1 clk = ~clk ; 
    end
end

initial begin
    RSTA = 1 ;        //     Verify Reset Operation
    RSTB = 1 ;
    RSTC = 1 ;
    RSTD = 1 ;
    RSTCARRYIN = 1 ;
    RSTM = 1;
    RSTOPMODE = 1 ;
    RSTP = 1 ;
    CEA = $random ; 
    CEB = $random ; 
    CEC = $random ;
    CED = $random ;
    CECARRYIN = $random ;
    CEM = $random ;
    CEP = $random ;
    CEOPMODE = $random ;
    A = $random ;
    B = $random ;
    C = $random ;
    D = $random ;
    BCIN = $random ;
    CARRYIN = $random ;
    opmode = $random ;
    PCIN = $random ;

    @(negedge clk ) ; 

    if (P != 0 || PCOUT != 0 || M != 0 || BCOUT != 0 || CARRYOUT != 0 || CARRYOUTF != 0) begin 
        $display ("ERROR IN RESET OPERATION ") ;
        $stop ; 
    end

    RSTA = 0;        //     Verify Path 1
    RSTB = 0 ;
    RSTC = 0 ;
    RSTD = 0 ;
    RSTCARRYIN = 0 ;
    RSTM = 0;
    RSTOPMODE = 0 ;
    RSTP = 0 ;
    CEA = 1 ; 
    CEB = 1 ; 
    CEC = 1 ;
    CED = 1 ;
    CECARRYIN = 1;
    CEM = 1 ;
    CEP = 1 ;
    CEOPMODE = 1 ;
    A = 20 ;
    B = 10 ;
    C = 350 ;
    D = 25 ;
    BCIN = $random ;
    CARRYIN = $random ;
    opmode = 8'b11011101 ;
    PCIN = $random ;

    repeat (4) @(negedge clk ) ; 

    if (BCOUT != 'hf ||  M != 'h12c || P != 'h32 || PCOUT != 'h32 || CARRYOUT != 0 || CARRYOUTF != 0  ) begin
        $display ("ERROR IN PATH 1 ") ;
        $stop ; 
    end

    A = 20 ;           //     Verify Path 2
    B = 10 ;
    C = 350 ;
    D = 25 ;
    BCIN = $random ;
    CARRYIN = $random ;
    opmode = 8'b00010000 ;
    PCIN = $random ;

    repeat (3) @(negedge clk ) ; 

    if (BCOUT != 'h23 ||  M != 'h2bc || P != 0 || PCOUT != 0 || CARRYOUT != 0 || CARRYOUTF != 0  ) begin
        $display ("ERROR IN PATH 2 ") ;
        $stop ; 
    end

    A = 20 ;           //     Verify Path 3
    B = 10 ;
    C = 350 ;
    D = 25 ;
    BCIN = $random ;
    CARRYIN = $random ;
    opmode = 8'b00001010 ;
    PCIN = $random ;
    
    repeat (3) @(negedge clk ) ; 

    if (BCOUT != 'ha ||  M != 'hc8 || P != 0 || PCOUT != 0 || CARRYOUT != 0 || CARRYOUTF != 0  ) begin
        $display ("ERROR IN PATH 3 ") ;
        $stop ; 
    end

    A = 5 ;           //     Verify Path 4
    B = 6 ;
    C = 350 ;
    D = 25 ;
    BCIN = $random ;
    CARRYIN = $random ;
    opmode = 8'b10100111 ;
    PCIN = 3000 ;
    
    repeat (3) @(negedge clk ) ; 

    if (BCOUT != 'h6 ||  M != 'h1e || P != 'hfe6fffec0bb1 || PCOUT != 'hfe6fffec0bb1 || CARRYOUT != 1 || CARRYOUTF != 1 ) begin
        $display ("ERROR IN PATH 4 ") ;
        $stop ; 
    end

    $stop ;
end


endmodule