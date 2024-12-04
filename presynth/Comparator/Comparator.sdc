###################################################################

# Created by write_sdc on Fri Nov 29 20:34:41 2024

###################################################################
set sdc_version 2.1

set_units -time ns -resistance kOhm -capacitance pF -voltage V -current A
set_wire_load_mode top
set_wire_load_model -name tsmcwire -library lec25dscc25_TT
set_max_delay 1.6  -from [list [get_ports {A[191]}] [get_ports {A[190]}] [get_ports {A[189]}]    \
[get_ports {A[188]}] [get_ports {A[187]}] [get_ports {A[186]}] [get_ports      \
{A[185]}] [get_ports {A[184]}] [get_ports {A[183]}] [get_ports {A[182]}]       \
[get_ports {A[181]}] [get_ports {A[180]}] [get_ports {A[179]}] [get_ports      \
{A[178]}] [get_ports {A[177]}] [get_ports {A[176]}] [get_ports {A[175]}]       \
[get_ports {A[174]}] [get_ports {A[173]}] [get_ports {A[172]}] [get_ports      \
{A[171]}] [get_ports {A[170]}] [get_ports {A[169]}] [get_ports {A[168]}]       \
[get_ports {A[167]}] [get_ports {A[166]}] [get_ports {A[165]}] [get_ports      \
{A[164]}] [get_ports {A[163]}] [get_ports {A[162]}] [get_ports {A[161]}]       \
[get_ports {A[160]}] [get_ports {A[159]}] [get_ports {A[158]}] [get_ports      \
{A[157]}] [get_ports {A[156]}] [get_ports {A[155]}] [get_ports {A[154]}]       \
[get_ports {A[153]}] [get_ports {A[152]}] [get_ports {A[151]}] [get_ports      \
{A[150]}] [get_ports {A[149]}] [get_ports {A[148]}] [get_ports {A[147]}]       \
[get_ports {A[146]}] [get_ports {A[145]}] [get_ports {A[144]}] [get_ports      \
{A[143]}] [get_ports {A[142]}] [get_ports {A[141]}] [get_ports {A[140]}]       \
[get_ports {A[139]}] [get_ports {A[138]}] [get_ports {A[137]}] [get_ports      \
{A[136]}] [get_ports {A[135]}] [get_ports {A[134]}] [get_ports {A[133]}]       \
[get_ports {A[132]}] [get_ports {A[131]}] [get_ports {A[130]}] [get_ports      \
{A[129]}] [get_ports {A[128]}] [get_ports {A[127]}] [get_ports {A[126]}]       \
[get_ports {A[125]}] [get_ports {A[124]}] [get_ports {A[123]}] [get_ports      \
{A[122]}] [get_ports {A[121]}] [get_ports {A[120]}] [get_ports {A[119]}]       \
[get_ports {A[118]}] [get_ports {A[117]}] [get_ports {A[116]}] [get_ports      \
{A[115]}] [get_ports {A[114]}] [get_ports {A[113]}] [get_ports {A[112]}]       \
[get_ports {A[111]}] [get_ports {A[110]}] [get_ports {A[109]}] [get_ports      \
{A[108]}] [get_ports {A[107]}] [get_ports {A[106]}] [get_ports {A[105]}]       \
[get_ports {A[104]}] [get_ports {A[103]}] [get_ports {A[102]}] [get_ports      \
{A[101]}] [get_ports {A[100]}] [get_ports {A[99]}] [get_ports {A[98]}]         \
[get_ports {A[97]}] [get_ports {A[96]}] [get_ports {A[95]}] [get_ports         \
{A[94]}] [get_ports {A[93]}] [get_ports {A[92]}] [get_ports {A[91]}]           \
[get_ports {A[90]}] [get_ports {A[89]}] [get_ports {A[88]}] [get_ports         \
{A[87]}] [get_ports {A[86]}] [get_ports {A[85]}] [get_ports {A[84]}]           \
[get_ports {A[83]}] [get_ports {A[82]}] [get_ports {A[81]}] [get_ports         \
{A[80]}] [get_ports {A[79]}] [get_ports {A[78]}] [get_ports {A[77]}]           \
[get_ports {A[76]}] [get_ports {A[75]}] [get_ports {A[74]}] [get_ports         \
{A[73]}] [get_ports {A[72]}] [get_ports {A[71]}] [get_ports {A[70]}]           \
[get_ports {A[69]}] [get_ports {A[68]}] [get_ports {A[67]}] [get_ports         \
{A[66]}] [get_ports {A[65]}] [get_ports {A[64]}] [get_ports {A[63]}]           \
[get_ports {A[62]}] [get_ports {A[61]}] [get_ports {A[60]}] [get_ports         \
{A[59]}] [get_ports {A[58]}] [get_ports {A[57]}] [get_ports {A[56]}]           \
[get_ports {A[55]}] [get_ports {A[54]}] [get_ports {A[53]}] [get_ports         \
{A[52]}] [get_ports {A[51]}] [get_ports {A[50]}] [get_ports {A[49]}]           \
[get_ports {A[48]}] [get_ports {A[47]}] [get_ports {A[46]}] [get_ports         \
{A[45]}] [get_ports {A[44]}] [get_ports {A[43]}] [get_ports {A[42]}]           \
[get_ports {A[41]}] [get_ports {A[40]}] [get_ports {A[39]}] [get_ports         \
{A[38]}] [get_ports {A[37]}] [get_ports {A[36]}] [get_ports {A[35]}]           \
[get_ports {A[34]}] [get_ports {A[33]}] [get_ports {A[32]}] [get_ports         \
{A[31]}] [get_ports {A[30]}] [get_ports {A[29]}] [get_ports {A[28]}]           \
[get_ports {A[27]}] [get_ports {A[26]}] [get_ports {A[25]}] [get_ports         \
{A[24]}] [get_ports {A[23]}] [get_ports {A[22]}] [get_ports {A[21]}]           \
[get_ports {A[20]}] [get_ports {A[19]}] [get_ports {A[18]}] [get_ports         \
{A[17]}] [get_ports {A[16]}] [get_ports {A[15]}] [get_ports {A[14]}]           \
[get_ports {A[13]}] [get_ports {A[12]}] [get_ports {A[11]}] [get_ports         \
{A[10]}] [get_ports {A[9]}] [get_ports {A[8]}] [get_ports {A[7]}] [get_ports   \
{A[6]}] [get_ports {A[5]}] [get_ports {A[4]}] [get_ports {A[3]}] [get_ports    \
{A[2]}] [get_ports {A[1]}] [get_ports {A[0]}] [get_ports {B[191]}] [get_ports  \
{B[190]}] [get_ports {B[189]}] [get_ports {B[188]}] [get_ports {B[187]}]       \
[get_ports {B[186]}] [get_ports {B[185]}] [get_ports {B[184]}] [get_ports      \
{B[183]}] [get_ports {B[182]}] [get_ports {B[181]}] [get_ports {B[180]}]       \
[get_ports {B[179]}] [get_ports {B[178]}] [get_ports {B[177]}] [get_ports      \
{B[176]}] [get_ports {B[175]}] [get_ports {B[174]}] [get_ports {B[173]}]       \
[get_ports {B[172]}] [get_ports {B[171]}] [get_ports {B[170]}] [get_ports      \
{B[169]}] [get_ports {B[168]}] [get_ports {B[167]}] [get_ports {B[166]}]       \
[get_ports {B[165]}] [get_ports {B[164]}] [get_ports {B[163]}] [get_ports      \
{B[162]}] [get_ports {B[161]}] [get_ports {B[160]}] [get_ports {B[159]}]       \
[get_ports {B[158]}] [get_ports {B[157]}] [get_ports {B[156]}] [get_ports      \
{B[155]}] [get_ports {B[154]}] [get_ports {B[153]}] [get_ports {B[152]}]       \
[get_ports {B[151]}] [get_ports {B[150]}] [get_ports {B[149]}] [get_ports      \
{B[148]}] [get_ports {B[147]}] [get_ports {B[146]}] [get_ports {B[145]}]       \
[get_ports {B[144]}] [get_ports {B[143]}] [get_ports {B[142]}] [get_ports      \
{B[141]}] [get_ports {B[140]}] [get_ports {B[139]}] [get_ports {B[138]}]       \
[get_ports {B[137]}] [get_ports {B[136]}] [get_ports {B[135]}] [get_ports      \
{B[134]}] [get_ports {B[133]}] [get_ports {B[132]}] [get_ports {B[131]}]       \
[get_ports {B[130]}] [get_ports {B[129]}] [get_ports {B[128]}] [get_ports      \
{B[127]}] [get_ports {B[126]}] [get_ports {B[125]}] [get_ports {B[124]}]       \
[get_ports {B[123]}] [get_ports {B[122]}] [get_ports {B[121]}] [get_ports      \
{B[120]}] [get_ports {B[119]}] [get_ports {B[118]}] [get_ports {B[117]}]       \
[get_ports {B[116]}] [get_ports {B[115]}] [get_ports {B[114]}] [get_ports      \
{B[113]}] [get_ports {B[112]}] [get_ports {B[111]}] [get_ports {B[110]}]       \
[get_ports {B[109]}] [get_ports {B[108]}] [get_ports {B[107]}] [get_ports      \
{B[106]}] [get_ports {B[105]}] [get_ports {B[104]}] [get_ports {B[103]}]       \
[get_ports {B[102]}] [get_ports {B[101]}] [get_ports {B[100]}] [get_ports      \
{B[99]}] [get_ports {B[98]}] [get_ports {B[97]}] [get_ports {B[96]}]           \
[get_ports {B[95]}] [get_ports {B[94]}] [get_ports {B[93]}] [get_ports         \
{B[92]}] [get_ports {B[91]}] [get_ports {B[90]}] [get_ports {B[89]}]           \
[get_ports {B[88]}] [get_ports {B[87]}] [get_ports {B[86]}] [get_ports         \
{B[85]}] [get_ports {B[84]}] [get_ports {B[83]}] [get_ports {B[82]}]           \
[get_ports {B[81]}] [get_ports {B[80]}] [get_ports {B[79]}] [get_ports         \
{B[78]}] [get_ports {B[77]}] [get_ports {B[76]}] [get_ports {B[75]}]           \
[get_ports {B[74]}] [get_ports {B[73]}] [get_ports {B[72]}] [get_ports         \
{B[71]}] [get_ports {B[70]}] [get_ports {B[69]}] [get_ports {B[68]}]           \
[get_ports {B[67]}] [get_ports {B[66]}] [get_ports {B[65]}] [get_ports         \
{B[64]}] [get_ports {B[63]}] [get_ports {B[62]}] [get_ports {B[61]}]           \
[get_ports {B[60]}] [get_ports {B[59]}] [get_ports {B[58]}] [get_ports         \
{B[57]}] [get_ports {B[56]}] [get_ports {B[55]}] [get_ports {B[54]}]           \
[get_ports {B[53]}] [get_ports {B[52]}] [get_ports {B[51]}] [get_ports         \
{B[50]}] [get_ports {B[49]}] [get_ports {B[48]}] [get_ports {B[47]}]           \
[get_ports {B[46]}] [get_ports {B[45]}] [get_ports {B[44]}] [get_ports         \
{B[43]}] [get_ports {B[42]}] [get_ports {B[41]}] [get_ports {B[40]}]           \
[get_ports {B[39]}] [get_ports {B[38]}] [get_ports {B[37]}] [get_ports         \
{B[36]}] [get_ports {B[35]}] [get_ports {B[34]}] [get_ports {B[33]}]           \
[get_ports {B[32]}] [get_ports {B[31]}] [get_ports {B[30]}] [get_ports         \
{B[29]}] [get_ports {B[28]}] [get_ports {B[27]}] [get_ports {B[26]}]           \
[get_ports {B[25]}] [get_ports {B[24]}] [get_ports {B[23]}] [get_ports         \
{B[22]}] [get_ports {B[21]}] [get_ports {B[20]}] [get_ports {B[19]}]           \
[get_ports {B[18]}] [get_ports {B[17]}] [get_ports {B[16]}] [get_ports         \
{B[15]}] [get_ports {B[14]}] [get_ports {B[13]}] [get_ports {B[12]}]           \
[get_ports {B[11]}] [get_ports {B[10]}] [get_ports {B[9]}] [get_ports {B[8]}]  \
[get_ports {B[7]}] [get_ports {B[6]}] [get_ports {B[5]}] [get_ports {B[4]}]    \
[get_ports {B[3]}] [get_ports {B[2]}] [get_ports {B[1]}] [get_ports {B[0]}]]  -to [get_ports out]
