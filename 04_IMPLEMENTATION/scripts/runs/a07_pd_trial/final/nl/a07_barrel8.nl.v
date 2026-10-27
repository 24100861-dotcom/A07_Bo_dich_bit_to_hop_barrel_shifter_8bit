module a07_barrel8 (din,
    dout,
    mode,
    shamt);
 input [7:0] din;
 output [7:0] dout;
 input [1:0] mode;
 input [2:0] shamt;

 wire _000_;
 wire _001_;
 wire _002_;
 wire _003_;
 wire _004_;
 wire _005_;
 wire _006_;
 wire _007_;
 wire _008_;
 wire _009_;
 wire _010_;
 wire _011_;
 wire _012_;
 wire _013_;
 wire _014_;
 wire _015_;
 wire _016_;
 wire _017_;
 wire _018_;
 wire _019_;
 wire _020_;
 wire _021_;
 wire _022_;
 wire _023_;
 wire _024_;
 wire _025_;
 wire _026_;
 wire _027_;
 wire _028_;
 wire _029_;
 wire _030_;
 wire _031_;
 wire _032_;
 wire _033_;
 wire _034_;
 wire _035_;
 wire _036_;
 wire _037_;
 wire _038_;
 wire _039_;
 wire _040_;
 wire _041_;
 wire _042_;
 wire _043_;
 wire _044_;
 wire _045_;
 wire _046_;
 wire _047_;
 wire _048_;
 wire _049_;
 wire net1;
 wire net2;
 wire net3;
 wire net4;
 wire net5;
 wire net6;
 wire net7;
 wire net8;
 wire net14;
 wire net15;
 wire net16;
 wire net17;
 wire net18;
 wire net19;
 wire net20;
 wire net21;
 wire net9;
 wire net10;
 wire net11;
 wire net12;
 wire net13;

 sky130_fd_sc_hd__decap_3 FILLER_0_21 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_24 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_27 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_3 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_37 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_40 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_57 ();
 sky130_fd_sc_hd__fill_1 FILLER_10_19 ();
 sky130_fd_sc_hd__fill_1 FILLER_10_27 ();
 sky130_fd_sc_hd__fill_2 FILLER_10_3 ();
 sky130_fd_sc_hd__decap_3 FILLER_10_36 ();
 sky130_fd_sc_hd__decap_3 FILLER_10_39 ();
 sky130_fd_sc_hd__decap_3 FILLER_10_50 ();
 sky130_fd_sc_hd__fill_1 FILLER_10_62 ();
 sky130_fd_sc_hd__decap_3 FILLER_10_70 ();
 sky130_fd_sc_hd__fill_2 FILLER_10_73 ();
 sky130_fd_sc_hd__fill_2 FILLER_11_23 ();
 sky130_fd_sc_hd__decap_3 FILLER_11_3 ();
 sky130_fd_sc_hd__decap_3 FILLER_11_34 ();
 sky130_fd_sc_hd__decap_3 FILLER_11_37 ();
 sky130_fd_sc_hd__fill_2 FILLER_11_54 ();
 sky130_fd_sc_hd__fill_2 FILLER_11_57 ();
 sky130_fd_sc_hd__fill_1 FILLER_11_6 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_11 ();
 sky130_fd_sc_hd__fill_2 FILLER_12_14 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_21 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_24 ();
 sky130_fd_sc_hd__fill_1 FILLER_12_27 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_29 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_32 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_35 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_38 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_41 ();
 sky130_fd_sc_hd__fill_1 FILLER_12_44 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_53 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_57 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_60 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_71 ();
 sky130_fd_sc_hd__fill_1 FILLER_12_74 ();
 sky130_fd_sc_hd__decap_3 FILLER_1_15 ();
 sky130_fd_sc_hd__decap_3 FILLER_1_3 ();
 sky130_fd_sc_hd__decap_3 FILLER_1_37 ();
 sky130_fd_sc_hd__fill_1 FILLER_1_55 ();
 sky130_fd_sc_hd__fill_2 FILLER_1_73 ();
 sky130_fd_sc_hd__fill_1 FILLER_2_27 ();
 sky130_fd_sc_hd__decap_3 FILLER_2_29 ();
 sky130_fd_sc_hd__decap_3 FILLER_2_32 ();
 sky130_fd_sc_hd__decap_3 FILLER_2_35 ();
 sky130_fd_sc_hd__decap_3 FILLER_2_38 ();
 sky130_fd_sc_hd__fill_2 FILLER_2_57 ();
 sky130_fd_sc_hd__decap_3 FILLER_3_15 ();
 sky130_fd_sc_hd__decap_3 FILLER_3_18 ();
 sky130_fd_sc_hd__decap_3 FILLER_3_21 ();
 sky130_fd_sc_hd__fill_1 FILLER_3_24 ();
 sky130_fd_sc_hd__decap_3 FILLER_3_3 ();
 sky130_fd_sc_hd__decap_3 FILLER_3_31 ();
 sky130_fd_sc_hd__decap_3 FILLER_3_34 ();
 sky130_fd_sc_hd__decap_3 FILLER_3_37 ();
 sky130_fd_sc_hd__decap_3 FILLER_3_40 ();
 sky130_fd_sc_hd__fill_1 FILLER_3_43 ();
 sky130_fd_sc_hd__decap_3 FILLER_3_53 ();
 sky130_fd_sc_hd__decap_3 FILLER_3_57 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_16 ();
 sky130_fd_sc_hd__fill_1 FILLER_4_19 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_29 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_3 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_32 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_35 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_38 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_50 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_53 ();
 sky130_fd_sc_hd__fill_2 FILLER_4_56 ();
 sky130_fd_sc_hd__fill_1 FILLER_4_6 ();
 sky130_fd_sc_hd__fill_1 FILLER_4_74 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_17 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_20 ();
 sky130_fd_sc_hd__fill_1 FILLER_5_23 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_32 ();
 sky130_fd_sc_hd__fill_2 FILLER_5_35 ();
 sky130_fd_sc_hd__fill_2 FILLER_5_54 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_57 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_60 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_63 ();
 sky130_fd_sc_hd__fill_1 FILLER_5_66 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_14 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_17 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_20 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_23 ();
 sky130_fd_sc_hd__fill_2 FILLER_6_26 ();
 sky130_fd_sc_hd__fill_2 FILLER_6_29 ();
 sky130_fd_sc_hd__fill_2 FILLER_6_3 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_36 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_39 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_42 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_45 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_48 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_51 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_54 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_57 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_60 ();
 sky130_fd_sc_hd__fill_2 FILLER_6_63 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_72 ();
 sky130_fd_sc_hd__decap_3 FILLER_7_3 ();
 sky130_fd_sc_hd__decap_3 FILLER_7_33 ();
 sky130_fd_sc_hd__decap_3 FILLER_7_36 ();
 sky130_fd_sc_hd__decap_3 FILLER_7_39 ();
 sky130_fd_sc_hd__fill_2 FILLER_7_42 ();
 sky130_fd_sc_hd__decap_3 FILLER_7_52 ();
 sky130_fd_sc_hd__fill_1 FILLER_7_55 ();
 sky130_fd_sc_hd__fill_1 FILLER_7_6 ();
 sky130_fd_sc_hd__fill_2 FILLER_7_73 ();
 sky130_fd_sc_hd__decap_3 FILLER_8_19 ();
 sky130_fd_sc_hd__decap_3 FILLER_8_22 ();
 sky130_fd_sc_hd__decap_3 FILLER_8_25 ();
 sky130_fd_sc_hd__decap_3 FILLER_8_38 ();
 sky130_fd_sc_hd__decap_3 FILLER_8_41 ();
 sky130_fd_sc_hd__decap_3 FILLER_8_44 ();
 sky130_fd_sc_hd__fill_2 FILLER_8_57 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_11 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_14 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_17 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_20 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_23 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_26 ();
 sky130_fd_sc_hd__fill_1 FILLER_9_29 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_35 ();
 sky130_fd_sc_hd__fill_2 FILLER_9_38 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_49 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_52 ();
 sky130_fd_sc_hd__fill_1 FILLER_9_55 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_57 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_60 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_63 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_0_Left_13 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_0_Right_0 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_10_Left_23 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_10_Right_10 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_11_Left_24 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_11_Right_11 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_12_Left_25 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_12_Right_12 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_1_Left_14 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_1_Right_1 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_2_Left_15 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_2_Right_2 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_3_Left_16 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_3_Right_3 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_4_Left_17 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_4_Right_4 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_5_Left_18 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_5_Right_5 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_6_Left_19 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_6_Right_6 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_7_Left_20 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_7_Right_7 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_8_Left_21 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_8_Right_8 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_9_Left_22 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_9_Right_9 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_0_26 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_0_27 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_10_37 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_11_38 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_12_39 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_12_40 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_1_28 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_2_29 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_3_30 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_4_31 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_5_32 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_6_33 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_7_34 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_8_35 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_9_36 ();
 sky130_fd_sc_hd__inv_2 _050_ (.A(net9),
    .Y(_000_));
 sky130_fd_sc_hd__inv_2 _051_ (.A(net11),
    .Y(_001_));
 sky130_fd_sc_hd__inv_2 _052_ (.A(net1),
    .Y(_002_));
 sky130_fd_sc_hd__and3_2 _053_ (.A(net9),
    .B(net10),
    .C(net8),
    .X(_003_));
 sky130_fd_sc_hd__nand3_2 _054_ (.A(net9),
    .B(net10),
    .C(net8),
    .Y(_004_));
 sky130_fd_sc_hd__and2_2 _055_ (.A(net13),
    .B(_004_),
    .X(_005_));
 sky130_fd_sc_hd__nand2_2 _056_ (.A(net13),
    .B(_004_),
    .Y(_006_));
 sky130_fd_sc_hd__and2b_2 _057_ (.A_N(net11),
    .B(net4),
    .X(_007_));
 sky130_fd_sc_hd__mux2_1 _058_ (.A0(net3),
    .A1(net5),
    .S(net9),
    .X(_008_));
 sky130_fd_sc_hd__a21oi_2 _059_ (.A1(net11),
    .A2(_008_),
    .B1(_007_),
    .Y(_009_));
 sky130_fd_sc_hd__and2b_2 _060_ (.A_N(net11),
    .B(net2),
    .X(_010_));
 sky130_fd_sc_hd__mux2_1 _061_ (.A0(net1),
    .A1(net3),
    .S(net9),
    .X(_011_));
 sky130_fd_sc_hd__a21oi_2 _062_ (.A1(net11),
    .A2(_011_),
    .B1(_010_),
    .Y(_012_));
 sky130_fd_sc_hd__nand2_2 _063_ (.A(_000_),
    .B(net12),
    .Y(_013_));
 sky130_fd_sc_hd__o22a_2 _064_ (.A1(net12),
    .A2(_009_),
    .B1(_012_),
    .B2(_013_),
    .X(_014_));
 sky130_fd_sc_hd__nor2_2 _065_ (.A(net9),
    .B(_014_),
    .Y(_015_));
 sky130_fd_sc_hd__a21o_2 _066_ (.A1(_000_),
    .A2(net7),
    .B1(_001_),
    .X(_016_));
 sky130_fd_sc_hd__o22a_2 _067_ (.A1(net8),
    .A2(net11),
    .B1(_003_),
    .B2(_016_),
    .X(_017_));
 sky130_fd_sc_hd__and2b_2 _068_ (.A_N(net11),
    .B(net6),
    .X(_018_));
 sky130_fd_sc_hd__mux2_1 _069_ (.A0(net5),
    .A1(net7),
    .S(net9),
    .X(_019_));
 sky130_fd_sc_hd__a21oi_2 _070_ (.A1(net11),
    .A2(_019_),
    .B1(_018_),
    .Y(_020_));
 sky130_fd_sc_hd__o21ai_2 _071_ (.A1(net9),
    .A2(_020_),
    .B1(_004_),
    .Y(_021_));
 sky130_fd_sc_hd__mux2_1 _072_ (.A0(_017_),
    .A1(_021_),
    .S(net12),
    .X(_022_));
 sky130_fd_sc_hd__o22a_2 _073_ (.A1(_006_),
    .A2(_015_),
    .B1(_022_),
    .B2(net13),
    .X(net21));
 sky130_fd_sc_hd__and2b_2 _074_ (.A_N(net11),
    .B(net3),
    .X(_023_));
 sky130_fd_sc_hd__mux2_1 _075_ (.A0(net2),
    .A1(net4),
    .S(net9),
    .X(_024_));
 sky130_fd_sc_hd__a21oi_2 _076_ (.A1(net11),
    .A2(_024_),
    .B1(_023_),
    .Y(_025_));
 sky130_fd_sc_hd__o32a_2 _077_ (.A1(net11),
    .A2(_002_),
    .A3(_013_),
    .B1(_025_),
    .B2(net12),
    .X(_026_));
 sky130_fd_sc_hd__nor2_2 _078_ (.A(net9),
    .B(_026_),
    .Y(_027_));
 sky130_fd_sc_hd__mux2_1 _079_ (.A0(net6),
    .A1(net8),
    .S(net9),
    .X(_028_));
 sky130_fd_sc_hd__mux2_1 _080_ (.A0(net7),
    .A1(_028_),
    .S(net11),
    .X(_029_));
 sky130_fd_sc_hd__mux2_1 _081_ (.A0(_029_),
    .A1(_003_),
    .S(net12),
    .X(_030_));
 sky130_fd_sc_hd__and2b_2 _082_ (.A_N(net11),
    .B(net5),
    .X(_031_));
 sky130_fd_sc_hd__mux2_1 _083_ (.A0(net4),
    .A1(net6),
    .S(net9),
    .X(_032_));
 sky130_fd_sc_hd__a21oi_2 _084_ (.A1(net11),
    .A2(_032_),
    .B1(_031_),
    .Y(_033_));
 sky130_fd_sc_hd__nor2_2 _085_ (.A(_013_),
    .B(_033_),
    .Y(_034_));
 sky130_fd_sc_hd__o32a_2 _086_ (.A1(net13),
    .A2(_030_),
    .A3(_034_),
    .B1(_006_),
    .B2(_027_),
    .X(net20));
 sky130_fd_sc_hd__or3_2 _087_ (.A(net9),
    .B(net12),
    .C(_012_),
    .X(_035_));
 sky130_fd_sc_hd__nor2_2 _088_ (.A(net12),
    .B(_020_),
    .Y(_036_));
 sky130_fd_sc_hd__nor2_2 _089_ (.A(_009_),
    .B(_013_),
    .Y(_037_));
 sky130_fd_sc_hd__nand2_2 _090_ (.A(net9),
    .B(net12),
    .Y(_038_));
 sky130_fd_sc_hd__a311o_2 _091_ (.A1(net9),
    .A2(net12),
    .A3(_017_),
    .B1(_036_),
    .C1(_037_),
    .X(_039_));
 sky130_fd_sc_hd__o2bb2a_2 _092_ (.A1_N(_005_),
    .A2_N(_035_),
    .B1(_039_),
    .B2(net13),
    .X(net19));
 sky130_fd_sc_hd__and3_2 _093_ (.A(net9),
    .B(net11),
    .C(net2),
    .X(_040_));
 sky130_fd_sc_hd__a21oi_2 _094_ (.A1(_001_),
    .A2(net1),
    .B1(_040_),
    .Y(_041_));
 sky130_fd_sc_hd__or3_2 _095_ (.A(net9),
    .B(net12),
    .C(_041_),
    .X(_042_));
 sky130_fd_sc_hd__o22ai_2 _096_ (.A1(_013_),
    .A2(_025_),
    .B1(_033_),
    .B2(net12),
    .Y(_043_));
 sky130_fd_sc_hd__a31o_2 _097_ (.A1(net9),
    .A2(net12),
    .A3(_029_),
    .B1(_043_),
    .X(_044_));
 sky130_fd_sc_hd__o2bb2a_2 _098_ (.A1_N(_005_),
    .A2_N(_042_),
    .B1(_044_),
    .B2(net13),
    .X(net18));
 sky130_fd_sc_hd__and2_2 _099_ (.A(net9),
    .B(net13),
    .X(_045_));
 sky130_fd_sc_hd__o21a_2 _100_ (.A1(_020_),
    .A2(_038_),
    .B1(_014_),
    .X(_046_));
 sky130_fd_sc_hd__a2bb2o_2 _101_ (.A1_N(net13),
    .A2_N(_046_),
    .B1(_045_),
    .B2(_022_),
    .X(net17));
 sky130_fd_sc_hd__o21a_2 _102_ (.A1(_033_),
    .A2(_038_),
    .B1(_026_),
    .X(_047_));
 sky130_fd_sc_hd__a2bb2o_2 _103_ (.A1_N(net13),
    .A2_N(_047_),
    .B1(_045_),
    .B2(_030_),
    .X(net16));
 sky130_fd_sc_hd__o22a_2 _104_ (.A1(net12),
    .A2(_012_),
    .B1(_038_),
    .B2(_009_),
    .X(_048_));
 sky130_fd_sc_hd__a2bb2o_2 _105_ (.A1_N(net13),
    .A2_N(_048_),
    .B1(_045_),
    .B2(_039_),
    .X(net15));
 sky130_fd_sc_hd__o22a_2 _106_ (.A1(_025_),
    .A2(_038_),
    .B1(_041_),
    .B2(net12),
    .X(_049_));
 sky130_fd_sc_hd__a2bb2o_2 _107_ (.A1_N(net13),
    .A2_N(_049_),
    .B1(_045_),
    .B2(_044_),
    .X(net14));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input1 (.A(din[0]),
    .X(net1));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input10 (.A(mode[1]),
    .X(net10));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input11 (.A(shamt[0]),
    .X(net11));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input12 (.A(shamt[1]),
    .X(net12));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input13 (.A(shamt[2]),
    .X(net13));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input2 (.A(din[1]),
    .X(net2));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input3 (.A(din[2]),
    .X(net3));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input4 (.A(din[3]),
    .X(net4));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input5 (.A(din[4]),
    .X(net5));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input6 (.A(din[5]),
    .X(net6));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input7 (.A(din[6]),
    .X(net7));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input8 (.A(din[7]),
    .X(net8));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input9 (.A(mode[0]),
    .X(net9));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output14 (.A(net14),
    .X(dout[0]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output15 (.A(net15),
    .X(dout[1]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output16 (.A(net16),
    .X(dout[2]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output17 (.A(net17),
    .X(dout[3]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output18 (.A(net18),
    .X(dout[4]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output19 (.A(net19),
    .X(dout[5]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output20 (.A(net20),
    .X(dout[6]));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output21 (.A(net21),
    .X(dout[7]));
endmodule
