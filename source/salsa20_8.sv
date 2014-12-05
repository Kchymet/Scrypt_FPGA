// $Id: $
// File name:   salsa20_8
// Created:     12/1/2014
// Author:      Kyle Chynoweth
// Lab Section: 01
// Version:     1.0  Initial Design Entry
// Description: Salsa 20/8 Component of the Core Scrypt Algorithm

module salsa20_8 (
  input wire clk,
  input wire n_rst,
  input wire[511:0] data, //data[15]..data[0], little endian
  input wire enable,
  output reg[511:0] data_out,
  output reg hash_done
);

typedef enum bit[3:0]{
  IDLE,
  ROUND1,
  ROUND2,
  ROUND3,
  ROUND4,
  ROUND5,
  ROUND6,
  ROUND7,
  ROUND8,
  DONE1,
  DONE2
} State;

//internal variables
State q, nextq;
shortint round, nextround;
reg[511:0] nextdata, data_store;
reg[31:0] addtmp1,addtmp2,addtmp3,addtmp4;
reg[31:0] rottmp1,rottmp2,rottmp3,rottmp4;

//nextstate logic
always_comb begin
  nextq=IDLE;
  case(q)
    IDLE: if(enable) begin nextq=ROUND1; end
    ROUND1: begin nextq=ROUND2; end
    ROUND2: begin nextq=ROUND3; end
    ROUND3: begin nextq=ROUND4; end
    ROUND4: begin nextq=ROUND5; end
    ROUND5: begin nextq=ROUND6; end
    ROUND6: begin nextq=ROUND7; end
    ROUND7: begin nextq=ROUND8; end
    ROUND8: if(round==6) begin nextq=DONE1; end else begin nextq=ROUND1; end
    DONE1: begin nextq=DONE2; end
    DONE2: begin nextq=IDLE; end
  endcase
end

//nextround logic
always_comb begin
  nextround=round;
  case(q)
    IDLE: nextround=0;
    ROUND8: nextround=round+2;
  endcase
end

//nextdata logic
always_comb begin
  data_store=data_store;
  addtmp1=0; addtmp2=0; addtmp3=0; addtmp4=0;
  rottmp1=0; rottmp2=0; rottmp3=0; rottmp4=0;
  nextdata=data_out;
  case(q)
    IDLE: if(enable) begin nextdata=data; data_store=data; end
    ROUND1: begin
      addtmp1=data_out[31:0]+data_out[415:384];
      addtmp2=data_out[191:160]+data_out[63:32];
      addtmp3=data_out[351:320]+data_out[223:192];
      addtmp4=data_out[511:480]+data_out[383:352];
      rottmp1={addtmp1[24:0],addtmp1[31:25]};
      rottmp2={addtmp2[24:0],addtmp2[31:25]};
      rottmp3={addtmp3[24:0],addtmp3[31:25]};
      rottmp4={addtmp4[24:0],addtmp4[31:25]};
      nextdata[159:128]=nextdata[159:128] ^ rottmp1;
      nextdata[319:288]=nextdata[319:288] ^ rottmp2;
      nextdata[479:448]=nextdata[479:448] ^ rottmp3;
      nextdata[127:96]=nextdata[128:96] ^ rottmp4;
      $info("next data: %h %h %h %h", nextdata[159:128],nextdata[319:288],nextdata[479:448],nextdata[127:96]);
    end
    ROUND2: begin
      addtmp1=data_out[159:128]+data_out[31:0];
      addtmp2=data_out[319:288]+data_out[191:160];
      addtmp3=data_out[479:448]+data_out[351:320];
      addtmp4=data_out[127:96]+data_out[511:480];
      rottmp1={addtmp1[22:0],addtmp1[31:23]};
      rottmp2={addtmp2[22:0],addtmp2[31:23]};
      rottmp3={addtmp3[22:0],addtmp3[31:23]};
      rottmp4={addtmp4[22:0],addtmp4[31:23]};
      nextdata[287:256]=data_out[287:256] ^ rottmp1;
      nextdata[447:416]=data_out[447:416] ^ rottmp2;
      nextdata[95:64]=data_out[95:64] ^ rottmp3;
      nextdata[255:224]=data_out[255:224] ^ rottmp4;
      $info("next data: %h %h %h %h", nextdata[287:256],nextdata[447:416],nextdata[95:64],nextdata[255:224]);
    end
    ROUND3: begin
      addtmp1=data_out[287:256]+data_out[159:128];
      addtmp2=data_out[447:416]+data_out[319:288];
      addtmp3=data_out[95:64]+data_out[479:448];
      addtmp4=data_out[255:224]+data_out[127:96];
      rottmp1={addtmp1[18:0],addtmp1[31:19]};
      rottmp2={addtmp2[18:0],addtmp2[31:19]};
      rottmp3={addtmp3[18:0],addtmp3[31:19]};
      rottmp4={addtmp4[18:0],addtmp4[31:19]};
      nextdata[415:384]=data_out[415:384] ^ rottmp1;
      nextdata[63:32]=data_out[63:32] ^ rottmp2;
      nextdata[223:192]=data_out[223:192] ^ rottmp3;
      nextdata[383:352]=data_out[383:352] ^ rottmp4;
      $info("next data: %h %h %h %h", nextdata[415:384],nextdata[63:32],nextdata[223:192],nextdata[383:352]);
    end
    ROUND4: begin
      addtmp1=data_out[415:384]+data_out[287:256];
      addtmp2=data_out[63:32]+data_out[447:416];
      addtmp3=data_out[223:192]+data_out[95:64];
      addtmp4=data_out[383:352]+data_out[255:224];
      rottmp1={addtmp1[13:0],addtmp1[31:14]};
      rottmp2={addtmp2[13:0],addtmp2[31:14]};
      rottmp3={addtmp3[13:0],addtmp3[31:14]};
      rottmp4={addtmp4[13:0],addtmp4[31:14]};
      nextdata[31:0]=data_out[31:0] ^ rottmp1;
      nextdata[191:160]=data_out[191:160] ^ rottmp2;
      nextdata[351:320]=data_out[351:320] ^ rottmp3;
      nextdata[511:480]=data_out[511:480] ^ rottmp4;
      $info("next data: %h %h %h %h", nextdata[31:0],nextdata[191:160],nextdata[351:320],nextdata[511:480]);
    end
    ROUND5: begin
      addtmp1=data_out[31:0]+data_out[127:96];
      addtmp2=data_out[191:160]+data_out[159:128];
      addtmp3=data_out[351:320]+data_out[319:288];
      addtmp4=data_out[511:480]+data_out[479:448];
      rottmp1={addtmp1[24:0],addtmp1[31:25]};
      rottmp2={addtmp2[24:0],addtmp2[31:25]};
      rottmp3={addtmp3[24:0],addtmp3[31:25]};
      rottmp4={addtmp4[24:0],addtmp4[31:25]};
      nextdata[63:32]=data_out[63:32] ^ rottmp1;
      nextdata[223:192]=data_out[223:192] ^ rottmp2;
      nextdata[383:352]=data_out[383:352] ^ rottmp3;
      nextdata[415:384]=data_out[415:384] ^ rottmp4;
      $info("next data: %h %h %h %h", nextdata[63:32],nextdata[223:192],nextdata[383:352],nextdata[415:384]);
    end
    ROUND6: begin
      addtmp1=data_out[63:32]+data_out[31:0];
      addtmp2=data_out[223:192]+data_out[191:160];
      addtmp3=data_out[383:352]+data_out[351:320];
      addtmp4=data_out[415:384]+data_out[511:480];
      rottmp1={addtmp1[22:0],addtmp1[31:23]};
      rottmp2={addtmp2[22:0],addtmp2[31:23]};
      rottmp3={addtmp3[22:0],addtmp3[31:23]};
      rottmp4={addtmp4[22:0],addtmp4[31:23]};
      nextdata[95:64]=data_out[95:64] ^ rottmp1;
      nextdata[255:224]=data_out[255:224] ^ rottmp2;
      nextdata[287:256]=data_out[287:256] ^ rottmp3;
      nextdata[448:416]=data_out[448:416] ^ rottmp4;
      $info("next data: %h %h %h %h", nextdata[95:64],nextdata[255:224],nextdata[287:256],nextdata[448:416]);
    end
    ROUND7: begin
      addtmp1=data_out[95:64]+data_out[63:32];
      addtmp2=data_out[255:224]+data_out[223:192];
      addtmp3=data_out[287:256]+data_out[383:352];
      addtmp4=data_out[447:416]+data_out[415:384];
      $info("%h = %h + %h",addtmp4,data_out[447:416],data_out[415:384]);
      rottmp1={addtmp1[18:0],addtmp1[31:19]};
      rottmp2={addtmp2[18:0],addtmp2[31:19]};
      rottmp3={addtmp3[18:0],addtmp3[31:19]};
      rottmp4={addtmp4[18:0],addtmp4[31:19]};
      nextdata[127:96]=data_out[127:96] ^ rottmp1;
      nextdata[159:128]=data_out[159:128] ^ rottmp2;
      nextdata[319:288]=data_out[319:288] ^ rottmp3;
      nextdata[479:448]=data_out[479:448] ^ rottmp4;
      $info("next data: %h %h %h %h", nextdata[127:96],nextdata[159:128],nextdata[319:288],nextdata[479:448]);
    end
    ROUND8: begin
      addtmp1=data_out[127:96]+data_out[95:64];
      addtmp2=data_out[159:128]+data_out[255:224];
      addtmp3=data_out[319:288]+data_out[287:256];
      addtmp4=data_out[479:448]+data_out[447:416];
      rottmp1={addtmp1[13:0],addtmp1[31:14]};
      rottmp2={addtmp2[13:0],addtmp2[31:14]};
      rottmp3={addtmp3[13:0],addtmp3[31:14]};
      rottmp4={addtmp4[13:0],addtmp4[31:14]};
      nextdata[31:0]=data_out[31:0] ^ rottmp1;
      nextdata[191:160]=data_out[191:160] ^ rottmp2;
      nextdata[351:320]=data_out[351:320] ^ rottmp3;
      nextdata[511:480]=data_out[511:480] ^ rottmp4;
      $info("next data: %h %h %h %h", nextdata[31:0],nextdata[191:160],nextdata[351:320],nextdata[511:480]);
    end
    DONE1: begin
      for(integer i=0;i<16;i=i+1) begin
        nextdata[(32*i) +: 32]=data_out[(32*i) +: 32]+data_store[(32*i) +: 32];
      end
    end
  endcase
end

//flipflop
always_ff @(posedge clk, negedge n_rst) begin
  if(n_rst==0) begin
    q<=IDLE;
  end
  else begin
    q<=nextq;
    round=nextround;
    data_out<=nextdata;
  end
end

//output logic
always_comb begin
  hash_done=0;
  case(q)
    DONE2: hash_done=1;
  endcase
end

endmodule