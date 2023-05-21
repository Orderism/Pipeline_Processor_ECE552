module  cla4b(inA, inB, sum, cIn, cOut);
//Make the inputs and outputs 4-bit buses (vectors) labeled 
//inA(3:0), inB(3:0), and sum(3:0)
//Label the carry-in cIn and the carry-out cOut
input wire [3:0]inA, inB;
input wire [3:0]sum;
input wire cIn;
output wire cOut;
//Logic for the propagate and generate
//p=inA*inB;
//g=inA+inB;


//P & G
wire [3:0]P;
wire [3:0]G;

or2 andP0(.out(P[0]), .in1(inA[0]), .in2(inB[0]));
or2 andP1(.out(P[1]), .in1(inA[1]), .in2(inB[1]));
or2 andP2(.out(P[2]), .in1(inA[2]), .in2(inB[2]));
or2 andP3(.out(P[3]), .in1(inA[3]), .in2(inB[3]));

and2 orG0(.out(G[0]), .in1(inA[0]), .in2(inB[0]));
and2 orG1(.out(G[1]), .in1(inA[1]), .in2(inB[1]));
and2 orG2(.out(G[2]), .in1(inA[2]), .in2(inB[2]));
and2 orG3(.out(G[3]), .in1(inA[3]), .in2(inB[3]));

//module fullAdder1b(inA, inB, cIn, s, cOut)
//Carry in
wire [3:0] C;//for the carry bits

//c[0]
assign C[0]=cIn;

fullAdder1b FA_S0(.inA(inA[0]), .inB(inB[0]), .cIn(C[0]), .s(sum[0]), .cOut());

//assign c[1]= g[0]|(p[0]&c[0]);
wire p0c0;
and2 and_p0c0(.out(p0c0), .in1(P[0]), .in2(C[0]));//p[0]&c[0]
or2 or_C1(.out(C[1]), .in1(G[0]), .in2(p0c0));//c[1]= g[0]|(p[0]&c[0]);

fullAdder1b FA_S1(.inA(inA[1]), .inB(inB[1]), .cIn(C[1]), .s(sum[1]), .cOut());



//assign c[2]= g[1] | (p[1]&g[0]) | p[1]&p[0]&c[0];
wire p1g0;
wire p1p0c0;
and2 and_p1g0(.out(p1g0), .in1(P[1]), .in2(G[0]));//p[1]&g[0]
and3 and_p1p0c0(.out(p1p0c0), .in1(P[1]), .in2(P[0]), .in3(C[0]));//p[1]&p[0]&c[0]
or3 or_C2(.out(C[2]), .in1(G[1]), .in2(p1g0), .in3(p1p0c0));//c[2]= g[1] | (p[1]&g[0]) | p[1]&p[0]&c[0]

fullAdder1b FA_S2(.inA(inA[2]), .inB(inB[2]), .cIn(C[2]), .s(sum[2]), .cOut());



//assign c[3]= g[2] | (p[2]&g[1]) | p[2]&p[1]&g[0] | p[2]&p[1]&p[0]&c[0];
wire p2g1;
wire p2p1g0;
wire p2p1p0;//p[2]&p[1]&p[0]&c[0]
wire p2p1p0c0;
wire C3_np;//last 3 term of the C3
and2 and_p2g1(.out(p2g1), .in1(P[2]), .in2(G[1]));//p[2]&g[1]
and3 and_p2p1g0(.out(p2p1g0), .in1(P[2]), .in2(P[1]), .in3(G[0]));//p[2]&p[1]&g[0]

and3 and_p2p1p0(.out(p2p1p0), .in1(P[2]), .in2(P[1]), .in3(P[0]));//p[2]&p[1]&p[0]&c[0];
and2 and_p2p1p0c0(.out(p2p1p0c0), .in1(p2p1p0), .in2(C[0]));//p[2]&p[1]&p[0]&c[0];
or3 orC3_np(.out(C3_np),. in1(p2g1), .in2(p2p1g0), .in3(p2p1p0c0));
or2 C3(.out(C[3]), .in1(C3_np), .in2(G[2]));

fullAdder1b FA_S3(.inA(inA[3]), .inB(inB[3]), .cIn(C[3]), .s(sum[3]), .cOut());// get the C[4] as the Cout



//For the cOut
//assign c[4]=g[3]|(p[3]&g[2])|(p3p2g1)|(p3p2p1g0)|(p3p2p1p0c0)
wire p3g2;
and2 and_p3g2(.out(p3g2),.in1(P[3]),.in2(G[2]));//p3p2
wire p3p2g1;
and3 and_p3p2g1(.out(p3p2g1), .in1(P[3]), .in2(P[2]), .in3(G[1]));//p3p2g1
wire p3p2p1g0;
wire p3p2p1;
and3 and_p3p2p1(.out(p3p2p1), .in1(P[3]), .in2(P[2]), .in3(P[1]));
and2 and_p3p2p1g0(.out(p3p2p1g0),.in1(p3p2p1),.in2(G[0]));//p3p2g1*g0
wire p3p2p1p0c0;
and2 and_p3p2p1p0c0(.out(p3p2p1p0c0),.in1(p3p2p1),.in2(p0c0));//p3p2p1*p0c0

wire c4_front;//g3 and p3p2 and p3p2g1
wire c4_post;// the rest
or3 or_4f(.out(c4_front), .in1(G[3]), .in2(p3g2), .in3(p3p2g1));
or2 or_4p(.out(c4_post), .in1(p3p2p1g0), .in2(p3p2p1p0c0));
or2 C4(.out(cOut), .in1(c4_front), .in2(c4_post));



//Pm & Gm





endmodule