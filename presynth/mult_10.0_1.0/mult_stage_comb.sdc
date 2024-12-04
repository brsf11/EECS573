###################################################################

# Created by write_sdc on Fri Nov 29 23:03:17 2024

###################################################################
set sdc_version 2.1

set_units -time ns -resistance kOhm -capacitance pF -voltage V -current A
set_wire_load_mode top
set_wire_load_model -name tsmcwire -library lec25dscc25_TT
set_max_delay 10  -from [list [get_ports {prev_sum[63]}] [get_ports {prev_sum[62]}] [get_ports  \
{prev_sum[61]}] [get_ports {prev_sum[60]}] [get_ports {prev_sum[59]}]          \
[get_ports {prev_sum[58]}] [get_ports {prev_sum[57]}] [get_ports               \
{prev_sum[56]}] [get_ports {prev_sum[55]}] [get_ports {prev_sum[54]}]          \
[get_ports {prev_sum[53]}] [get_ports {prev_sum[52]}] [get_ports               \
{prev_sum[51]}] [get_ports {prev_sum[50]}] [get_ports {prev_sum[49]}]          \
[get_ports {prev_sum[48]}] [get_ports {prev_sum[47]}] [get_ports               \
{prev_sum[46]}] [get_ports {prev_sum[45]}] [get_ports {prev_sum[44]}]          \
[get_ports {prev_sum[43]}] [get_ports {prev_sum[42]}] [get_ports               \
{prev_sum[41]}] [get_ports {prev_sum[40]}] [get_ports {prev_sum[39]}]          \
[get_ports {prev_sum[38]}] [get_ports {prev_sum[37]}] [get_ports               \
{prev_sum[36]}] [get_ports {prev_sum[35]}] [get_ports {prev_sum[34]}]          \
[get_ports {prev_sum[33]}] [get_ports {prev_sum[32]}] [get_ports               \
{prev_sum[31]}] [get_ports {prev_sum[30]}] [get_ports {prev_sum[29]}]          \
[get_ports {prev_sum[28]}] [get_ports {prev_sum[27]}] [get_ports               \
{prev_sum[26]}] [get_ports {prev_sum[25]}] [get_ports {prev_sum[24]}]          \
[get_ports {prev_sum[23]}] [get_ports {prev_sum[22]}] [get_ports               \
{prev_sum[21]}] [get_ports {prev_sum[20]}] [get_ports {prev_sum[19]}]          \
[get_ports {prev_sum[18]}] [get_ports {prev_sum[17]}] [get_ports               \
{prev_sum[16]}] [get_ports {prev_sum[15]}] [get_ports {prev_sum[14]}]          \
[get_ports {prev_sum[13]}] [get_ports {prev_sum[12]}] [get_ports               \
{prev_sum[11]}] [get_ports {prev_sum[10]}] [get_ports {prev_sum[9]}]           \
[get_ports {prev_sum[8]}] [get_ports {prev_sum[7]}] [get_ports {prev_sum[6]}]  \
[get_ports {prev_sum[5]}] [get_ports {prev_sum[4]}] [get_ports {prev_sum[3]}]  \
[get_ports {prev_sum[2]}] [get_ports {prev_sum[1]}] [get_ports {prev_sum[0]}]  \
[get_ports {mplier[63]}] [get_ports {mplier[62]}] [get_ports {mplier[61]}]     \
[get_ports {mplier[60]}] [get_ports {mplier[59]}] [get_ports {mplier[58]}]     \
[get_ports {mplier[57]}] [get_ports {mplier[56]}] [get_ports {mplier[55]}]     \
[get_ports {mplier[54]}] [get_ports {mplier[53]}] [get_ports {mplier[52]}]     \
[get_ports {mplier[51]}] [get_ports {mplier[50]}] [get_ports {mplier[49]}]     \
[get_ports {mplier[48]}] [get_ports {mplier[47]}] [get_ports {mplier[46]}]     \
[get_ports {mplier[45]}] [get_ports {mplier[44]}] [get_ports {mplier[43]}]     \
[get_ports {mplier[42]}] [get_ports {mplier[41]}] [get_ports {mplier[40]}]     \
[get_ports {mplier[39]}] [get_ports {mplier[38]}] [get_ports {mplier[37]}]     \
[get_ports {mplier[36]}] [get_ports {mplier[35]}] [get_ports {mplier[34]}]     \
[get_ports {mplier[33]}] [get_ports {mplier[32]}] [get_ports {mplier[31]}]     \
[get_ports {mplier[30]}] [get_ports {mplier[29]}] [get_ports {mplier[28]}]     \
[get_ports {mplier[27]}] [get_ports {mplier[26]}] [get_ports {mplier[25]}]     \
[get_ports {mplier[24]}] [get_ports {mplier[23]}] [get_ports {mplier[22]}]     \
[get_ports {mplier[21]}] [get_ports {mplier[20]}] [get_ports {mplier[19]}]     \
[get_ports {mplier[18]}] [get_ports {mplier[17]}] [get_ports {mplier[16]}]     \
[get_ports {mplier[15]}] [get_ports {mplier[14]}] [get_ports {mplier[13]}]     \
[get_ports {mplier[12]}] [get_ports {mplier[11]}] [get_ports {mplier[10]}]     \
[get_ports {mplier[9]}] [get_ports {mplier[8]}] [get_ports {mplier[7]}]        \
[get_ports {mplier[6]}] [get_ports {mplier[5]}] [get_ports {mplier[4]}]        \
[get_ports {mplier[3]}] [get_ports {mplier[2]}] [get_ports {mplier[1]}]        \
[get_ports {mplier[0]}] [get_ports {mcand[63]}] [get_ports {mcand[62]}]        \
[get_ports {mcand[61]}] [get_ports {mcand[60]}] [get_ports {mcand[59]}]        \
[get_ports {mcand[58]}] [get_ports {mcand[57]}] [get_ports {mcand[56]}]        \
[get_ports {mcand[55]}] [get_ports {mcand[54]}] [get_ports {mcand[53]}]        \
[get_ports {mcand[52]}] [get_ports {mcand[51]}] [get_ports {mcand[50]}]        \
[get_ports {mcand[49]}] [get_ports {mcand[48]}] [get_ports {mcand[47]}]        \
[get_ports {mcand[46]}] [get_ports {mcand[45]}] [get_ports {mcand[44]}]        \
[get_ports {mcand[43]}] [get_ports {mcand[42]}] [get_ports {mcand[41]}]        \
[get_ports {mcand[40]}] [get_ports {mcand[39]}] [get_ports {mcand[38]}]        \
[get_ports {mcand[37]}] [get_ports {mcand[36]}] [get_ports {mcand[35]}]        \
[get_ports {mcand[34]}] [get_ports {mcand[33]}] [get_ports {mcand[32]}]        \
[get_ports {mcand[31]}] [get_ports {mcand[30]}] [get_ports {mcand[29]}]        \
[get_ports {mcand[28]}] [get_ports {mcand[27]}] [get_ports {mcand[26]}]        \
[get_ports {mcand[25]}] [get_ports {mcand[24]}] [get_ports {mcand[23]}]        \
[get_ports {mcand[22]}] [get_ports {mcand[21]}] [get_ports {mcand[20]}]        \
[get_ports {mcand[19]}] [get_ports {mcand[18]}] [get_ports {mcand[17]}]        \
[get_ports {mcand[16]}] [get_ports {mcand[15]}] [get_ports {mcand[14]}]        \
[get_ports {mcand[13]}] [get_ports {mcand[12]}] [get_ports {mcand[11]}]        \
[get_ports {mcand[10]}] [get_ports {mcand[9]}] [get_ports {mcand[8]}]          \
[get_ports {mcand[7]}] [get_ports {mcand[6]}] [get_ports {mcand[5]}]           \
[get_ports {mcand[4]}] [get_ports {mcand[3]}] [get_ports {mcand[2]}]           \
[get_ports {mcand[1]}] [get_ports {mcand[0]}]]  -to [list [get_ports {product_sum[63]}] [get_ports {product_sum[62]}]         \
[get_ports {product_sum[61]}] [get_ports {product_sum[60]}] [get_ports         \
{product_sum[59]}] [get_ports {product_sum[58]}] [get_ports {product_sum[57]}] \
[get_ports {product_sum[56]}] [get_ports {product_sum[55]}] [get_ports         \
{product_sum[54]}] [get_ports {product_sum[53]}] [get_ports {product_sum[52]}] \
[get_ports {product_sum[51]}] [get_ports {product_sum[50]}] [get_ports         \
{product_sum[49]}] [get_ports {product_sum[48]}] [get_ports {product_sum[47]}] \
[get_ports {product_sum[46]}] [get_ports {product_sum[45]}] [get_ports         \
{product_sum[44]}] [get_ports {product_sum[43]}] [get_ports {product_sum[42]}] \
[get_ports {product_sum[41]}] [get_ports {product_sum[40]}] [get_ports         \
{product_sum[39]}] [get_ports {product_sum[38]}] [get_ports {product_sum[37]}] \
[get_ports {product_sum[36]}] [get_ports {product_sum[35]}] [get_ports         \
{product_sum[34]}] [get_ports {product_sum[33]}] [get_ports {product_sum[32]}] \
[get_ports {product_sum[31]}] [get_ports {product_sum[30]}] [get_ports         \
{product_sum[29]}] [get_ports {product_sum[28]}] [get_ports {product_sum[27]}] \
[get_ports {product_sum[26]}] [get_ports {product_sum[25]}] [get_ports         \
{product_sum[24]}] [get_ports {product_sum[23]}] [get_ports {product_sum[22]}] \
[get_ports {product_sum[21]}] [get_ports {product_sum[20]}] [get_ports         \
{product_sum[19]}] [get_ports {product_sum[18]}] [get_ports {product_sum[17]}] \
[get_ports {product_sum[16]}] [get_ports {product_sum[15]}] [get_ports         \
{product_sum[14]}] [get_ports {product_sum[13]}] [get_ports {product_sum[12]}] \
[get_ports {product_sum[11]}] [get_ports {product_sum[10]}] [get_ports         \
{product_sum[9]}] [get_ports {product_sum[8]}] [get_ports {product_sum[7]}]    \
[get_ports {product_sum[6]}] [get_ports {product_sum[5]}] [get_ports           \
{product_sum[4]}] [get_ports {product_sum[3]}] [get_ports {product_sum[2]}]    \
[get_ports {product_sum[1]}] [get_ports {product_sum[0]}] [get_ports           \
{shifted_mplier[63]}] [get_ports {shifted_mplier[62]}] [get_ports              \
{shifted_mplier[61]}] [get_ports {shifted_mplier[60]}] [get_ports              \
{shifted_mplier[59]}] [get_ports {shifted_mplier[58]}] [get_ports              \
{shifted_mplier[57]}] [get_ports {shifted_mplier[56]}] [get_ports              \
{shifted_mplier[55]}] [get_ports {shifted_mplier[54]}] [get_ports              \
{shifted_mplier[53]}] [get_ports {shifted_mplier[52]}] [get_ports              \
{shifted_mplier[51]}] [get_ports {shifted_mplier[50]}] [get_ports              \
{shifted_mplier[49]}] [get_ports {shifted_mplier[48]}] [get_ports              \
{shifted_mplier[47]}] [get_ports {shifted_mplier[46]}] [get_ports              \
{shifted_mplier[45]}] [get_ports {shifted_mplier[44]}] [get_ports              \
{shifted_mplier[43]}] [get_ports {shifted_mplier[42]}] [get_ports              \
{shifted_mplier[41]}] [get_ports {shifted_mplier[40]}] [get_ports              \
{shifted_mplier[39]}] [get_ports {shifted_mplier[38]}] [get_ports              \
{shifted_mplier[37]}] [get_ports {shifted_mplier[36]}] [get_ports              \
{shifted_mplier[35]}] [get_ports {shifted_mplier[34]}] [get_ports              \
{shifted_mplier[33]}] [get_ports {shifted_mplier[32]}] [get_ports              \
{shifted_mplier[31]}] [get_ports {shifted_mplier[30]}] [get_ports              \
{shifted_mplier[29]}] [get_ports {shifted_mplier[28]}] [get_ports              \
{shifted_mplier[27]}] [get_ports {shifted_mplier[26]}] [get_ports              \
{shifted_mplier[25]}] [get_ports {shifted_mplier[24]}] [get_ports              \
{shifted_mplier[23]}] [get_ports {shifted_mplier[22]}] [get_ports              \
{shifted_mplier[21]}] [get_ports {shifted_mplier[20]}] [get_ports              \
{shifted_mplier[19]}] [get_ports {shifted_mplier[18]}] [get_ports              \
{shifted_mplier[17]}] [get_ports {shifted_mplier[16]}] [get_ports              \
{shifted_mplier[15]}] [get_ports {shifted_mplier[14]}] [get_ports              \
{shifted_mplier[13]}] [get_ports {shifted_mplier[12]}] [get_ports              \
{shifted_mplier[11]}] [get_ports {shifted_mplier[10]}] [get_ports              \
{shifted_mplier[9]}] [get_ports {shifted_mplier[8]}] [get_ports                \
{shifted_mplier[7]}] [get_ports {shifted_mplier[6]}] [get_ports                \
{shifted_mplier[5]}] [get_ports {shifted_mplier[4]}] [get_ports                \
{shifted_mplier[3]}] [get_ports {shifted_mplier[2]}] [get_ports                \
{shifted_mplier[1]}] [get_ports {shifted_mplier[0]}] [get_ports                \
{shifted_mcand[63]}] [get_ports {shifted_mcand[62]}] [get_ports                \
{shifted_mcand[61]}] [get_ports {shifted_mcand[60]}] [get_ports                \
{shifted_mcand[59]}] [get_ports {shifted_mcand[58]}] [get_ports                \
{shifted_mcand[57]}] [get_ports {shifted_mcand[56]}] [get_ports                \
{shifted_mcand[55]}] [get_ports {shifted_mcand[54]}] [get_ports                \
{shifted_mcand[53]}] [get_ports {shifted_mcand[52]}] [get_ports                \
{shifted_mcand[51]}] [get_ports {shifted_mcand[50]}] [get_ports                \
{shifted_mcand[49]}] [get_ports {shifted_mcand[48]}] [get_ports                \
{shifted_mcand[47]}] [get_ports {shifted_mcand[46]}] [get_ports                \
{shifted_mcand[45]}] [get_ports {shifted_mcand[44]}] [get_ports                \
{shifted_mcand[43]}] [get_ports {shifted_mcand[42]}] [get_ports                \
{shifted_mcand[41]}] [get_ports {shifted_mcand[40]}] [get_ports                \
{shifted_mcand[39]}] [get_ports {shifted_mcand[38]}] [get_ports                \
{shifted_mcand[37]}] [get_ports {shifted_mcand[36]}] [get_ports                \
{shifted_mcand[35]}] [get_ports {shifted_mcand[34]}] [get_ports                \
{shifted_mcand[33]}] [get_ports {shifted_mcand[32]}] [get_ports                \
{shifted_mcand[31]}] [get_ports {shifted_mcand[30]}] [get_ports                \
{shifted_mcand[29]}] [get_ports {shifted_mcand[28]}] [get_ports                \
{shifted_mcand[27]}] [get_ports {shifted_mcand[26]}] [get_ports                \
{shifted_mcand[25]}] [get_ports {shifted_mcand[24]}] [get_ports                \
{shifted_mcand[23]}] [get_ports {shifted_mcand[22]}] [get_ports                \
{shifted_mcand[21]}] [get_ports {shifted_mcand[20]}] [get_ports                \
{shifted_mcand[19]}] [get_ports {shifted_mcand[18]}] [get_ports                \
{shifted_mcand[17]}] [get_ports {shifted_mcand[16]}] [get_ports                \
{shifted_mcand[15]}] [get_ports {shifted_mcand[14]}] [get_ports                \
{shifted_mcand[13]}] [get_ports {shifted_mcand[12]}] [get_ports                \
{shifted_mcand[11]}] [get_ports {shifted_mcand[10]}] [get_ports                \
{shifted_mcand[9]}] [get_ports {shifted_mcand[8]}] [get_ports                  \
{shifted_mcand[7]}] [get_ports {shifted_mcand[6]}] [get_ports                  \
{shifted_mcand[5]}] [get_ports {shifted_mcand[4]}] [get_ports                  \
{shifted_mcand[3]}] [get_ports {shifted_mcand[2]}] [get_ports                  \
{shifted_mcand[1]}] [get_ports {shifted_mcand[0]}]]
set_min_delay 1  -from [list [get_ports {prev_sum[63]}] [get_ports {prev_sum[62]}] [get_ports  \
{prev_sum[61]}] [get_ports {prev_sum[60]}] [get_ports {prev_sum[59]}]          \
[get_ports {prev_sum[58]}] [get_ports {prev_sum[57]}] [get_ports               \
{prev_sum[56]}] [get_ports {prev_sum[55]}] [get_ports {prev_sum[54]}]          \
[get_ports {prev_sum[53]}] [get_ports {prev_sum[52]}] [get_ports               \
{prev_sum[51]}] [get_ports {prev_sum[50]}] [get_ports {prev_sum[49]}]          \
[get_ports {prev_sum[48]}] [get_ports {prev_sum[47]}] [get_ports               \
{prev_sum[46]}] [get_ports {prev_sum[45]}] [get_ports {prev_sum[44]}]          \
[get_ports {prev_sum[43]}] [get_ports {prev_sum[42]}] [get_ports               \
{prev_sum[41]}] [get_ports {prev_sum[40]}] [get_ports {prev_sum[39]}]          \
[get_ports {prev_sum[38]}] [get_ports {prev_sum[37]}] [get_ports               \
{prev_sum[36]}] [get_ports {prev_sum[35]}] [get_ports {prev_sum[34]}]          \
[get_ports {prev_sum[33]}] [get_ports {prev_sum[32]}] [get_ports               \
{prev_sum[31]}] [get_ports {prev_sum[30]}] [get_ports {prev_sum[29]}]          \
[get_ports {prev_sum[28]}] [get_ports {prev_sum[27]}] [get_ports               \
{prev_sum[26]}] [get_ports {prev_sum[25]}] [get_ports {prev_sum[24]}]          \
[get_ports {prev_sum[23]}] [get_ports {prev_sum[22]}] [get_ports               \
{prev_sum[21]}] [get_ports {prev_sum[20]}] [get_ports {prev_sum[19]}]          \
[get_ports {prev_sum[18]}] [get_ports {prev_sum[17]}] [get_ports               \
{prev_sum[16]}] [get_ports {prev_sum[15]}] [get_ports {prev_sum[14]}]          \
[get_ports {prev_sum[13]}] [get_ports {prev_sum[12]}] [get_ports               \
{prev_sum[11]}] [get_ports {prev_sum[10]}] [get_ports {prev_sum[9]}]           \
[get_ports {prev_sum[8]}] [get_ports {prev_sum[7]}] [get_ports {prev_sum[6]}]  \
[get_ports {prev_sum[5]}] [get_ports {prev_sum[4]}] [get_ports {prev_sum[3]}]  \
[get_ports {prev_sum[2]}] [get_ports {prev_sum[1]}] [get_ports {prev_sum[0]}]  \
[get_ports {mplier[63]}] [get_ports {mplier[62]}] [get_ports {mplier[61]}]     \
[get_ports {mplier[60]}] [get_ports {mplier[59]}] [get_ports {mplier[58]}]     \
[get_ports {mplier[57]}] [get_ports {mplier[56]}] [get_ports {mplier[55]}]     \
[get_ports {mplier[54]}] [get_ports {mplier[53]}] [get_ports {mplier[52]}]     \
[get_ports {mplier[51]}] [get_ports {mplier[50]}] [get_ports {mplier[49]}]     \
[get_ports {mplier[48]}] [get_ports {mplier[47]}] [get_ports {mplier[46]}]     \
[get_ports {mplier[45]}] [get_ports {mplier[44]}] [get_ports {mplier[43]}]     \
[get_ports {mplier[42]}] [get_ports {mplier[41]}] [get_ports {mplier[40]}]     \
[get_ports {mplier[39]}] [get_ports {mplier[38]}] [get_ports {mplier[37]}]     \
[get_ports {mplier[36]}] [get_ports {mplier[35]}] [get_ports {mplier[34]}]     \
[get_ports {mplier[33]}] [get_ports {mplier[32]}] [get_ports {mplier[31]}]     \
[get_ports {mplier[30]}] [get_ports {mplier[29]}] [get_ports {mplier[28]}]     \
[get_ports {mplier[27]}] [get_ports {mplier[26]}] [get_ports {mplier[25]}]     \
[get_ports {mplier[24]}] [get_ports {mplier[23]}] [get_ports {mplier[22]}]     \
[get_ports {mplier[21]}] [get_ports {mplier[20]}] [get_ports {mplier[19]}]     \
[get_ports {mplier[18]}] [get_ports {mplier[17]}] [get_ports {mplier[16]}]     \
[get_ports {mplier[15]}] [get_ports {mplier[14]}] [get_ports {mplier[13]}]     \
[get_ports {mplier[12]}] [get_ports {mplier[11]}] [get_ports {mplier[10]}]     \
[get_ports {mplier[9]}] [get_ports {mplier[8]}] [get_ports {mplier[7]}]        \
[get_ports {mplier[6]}] [get_ports {mplier[5]}] [get_ports {mplier[4]}]        \
[get_ports {mplier[3]}] [get_ports {mplier[2]}] [get_ports {mplier[1]}]        \
[get_ports {mplier[0]}] [get_ports {mcand[63]}] [get_ports {mcand[62]}]        \
[get_ports {mcand[61]}] [get_ports {mcand[60]}] [get_ports {mcand[59]}]        \
[get_ports {mcand[58]}] [get_ports {mcand[57]}] [get_ports {mcand[56]}]        \
[get_ports {mcand[55]}] [get_ports {mcand[54]}] [get_ports {mcand[53]}]        \
[get_ports {mcand[52]}] [get_ports {mcand[51]}] [get_ports {mcand[50]}]        \
[get_ports {mcand[49]}] [get_ports {mcand[48]}] [get_ports {mcand[47]}]        \
[get_ports {mcand[46]}] [get_ports {mcand[45]}] [get_ports {mcand[44]}]        \
[get_ports {mcand[43]}] [get_ports {mcand[42]}] [get_ports {mcand[41]}]        \
[get_ports {mcand[40]}] [get_ports {mcand[39]}] [get_ports {mcand[38]}]        \
[get_ports {mcand[37]}] [get_ports {mcand[36]}] [get_ports {mcand[35]}]        \
[get_ports {mcand[34]}] [get_ports {mcand[33]}] [get_ports {mcand[32]}]        \
[get_ports {mcand[31]}] [get_ports {mcand[30]}] [get_ports {mcand[29]}]        \
[get_ports {mcand[28]}] [get_ports {mcand[27]}] [get_ports {mcand[26]}]        \
[get_ports {mcand[25]}] [get_ports {mcand[24]}] [get_ports {mcand[23]}]        \
[get_ports {mcand[22]}] [get_ports {mcand[21]}] [get_ports {mcand[20]}]        \
[get_ports {mcand[19]}] [get_ports {mcand[18]}] [get_ports {mcand[17]}]        \
[get_ports {mcand[16]}] [get_ports {mcand[15]}] [get_ports {mcand[14]}]        \
[get_ports {mcand[13]}] [get_ports {mcand[12]}] [get_ports {mcand[11]}]        \
[get_ports {mcand[10]}] [get_ports {mcand[9]}] [get_ports {mcand[8]}]          \
[get_ports {mcand[7]}] [get_ports {mcand[6]}] [get_ports {mcand[5]}]           \
[get_ports {mcand[4]}] [get_ports {mcand[3]}] [get_ports {mcand[2]}]           \
[get_ports {mcand[1]}] [get_ports {mcand[0]}]]  -to [list [get_ports {product_sum[63]}] [get_ports {product_sum[62]}]         \
[get_ports {product_sum[61]}] [get_ports {product_sum[60]}] [get_ports         \
{product_sum[59]}] [get_ports {product_sum[58]}] [get_ports {product_sum[57]}] \
[get_ports {product_sum[56]}] [get_ports {product_sum[55]}] [get_ports         \
{product_sum[54]}] [get_ports {product_sum[53]}] [get_ports {product_sum[52]}] \
[get_ports {product_sum[51]}] [get_ports {product_sum[50]}] [get_ports         \
{product_sum[49]}] [get_ports {product_sum[48]}] [get_ports {product_sum[47]}] \
[get_ports {product_sum[46]}] [get_ports {product_sum[45]}] [get_ports         \
{product_sum[44]}] [get_ports {product_sum[43]}] [get_ports {product_sum[42]}] \
[get_ports {product_sum[41]}] [get_ports {product_sum[40]}] [get_ports         \
{product_sum[39]}] [get_ports {product_sum[38]}] [get_ports {product_sum[37]}] \
[get_ports {product_sum[36]}] [get_ports {product_sum[35]}] [get_ports         \
{product_sum[34]}] [get_ports {product_sum[33]}] [get_ports {product_sum[32]}] \
[get_ports {product_sum[31]}] [get_ports {product_sum[30]}] [get_ports         \
{product_sum[29]}] [get_ports {product_sum[28]}] [get_ports {product_sum[27]}] \
[get_ports {product_sum[26]}] [get_ports {product_sum[25]}] [get_ports         \
{product_sum[24]}] [get_ports {product_sum[23]}] [get_ports {product_sum[22]}] \
[get_ports {product_sum[21]}] [get_ports {product_sum[20]}] [get_ports         \
{product_sum[19]}] [get_ports {product_sum[18]}] [get_ports {product_sum[17]}] \
[get_ports {product_sum[16]}] [get_ports {product_sum[15]}] [get_ports         \
{product_sum[14]}] [get_ports {product_sum[13]}] [get_ports {product_sum[12]}] \
[get_ports {product_sum[11]}] [get_ports {product_sum[10]}] [get_ports         \
{product_sum[9]}] [get_ports {product_sum[8]}] [get_ports {product_sum[7]}]    \
[get_ports {product_sum[6]}] [get_ports {product_sum[5]}] [get_ports           \
{product_sum[4]}] [get_ports {product_sum[3]}] [get_ports {product_sum[2]}]    \
[get_ports {product_sum[1]}] [get_ports {product_sum[0]}] [get_ports           \
{shifted_mplier[63]}] [get_ports {shifted_mplier[62]}] [get_ports              \
{shifted_mplier[61]}] [get_ports {shifted_mplier[60]}] [get_ports              \
{shifted_mplier[59]}] [get_ports {shifted_mplier[58]}] [get_ports              \
{shifted_mplier[57]}] [get_ports {shifted_mplier[56]}] [get_ports              \
{shifted_mplier[55]}] [get_ports {shifted_mplier[54]}] [get_ports              \
{shifted_mplier[53]}] [get_ports {shifted_mplier[52]}] [get_ports              \
{shifted_mplier[51]}] [get_ports {shifted_mplier[50]}] [get_ports              \
{shifted_mplier[49]}] [get_ports {shifted_mplier[48]}] [get_ports              \
{shifted_mplier[47]}] [get_ports {shifted_mplier[46]}] [get_ports              \
{shifted_mplier[45]}] [get_ports {shifted_mplier[44]}] [get_ports              \
{shifted_mplier[43]}] [get_ports {shifted_mplier[42]}] [get_ports              \
{shifted_mplier[41]}] [get_ports {shifted_mplier[40]}] [get_ports              \
{shifted_mplier[39]}] [get_ports {shifted_mplier[38]}] [get_ports              \
{shifted_mplier[37]}] [get_ports {shifted_mplier[36]}] [get_ports              \
{shifted_mplier[35]}] [get_ports {shifted_mplier[34]}] [get_ports              \
{shifted_mplier[33]}] [get_ports {shifted_mplier[32]}] [get_ports              \
{shifted_mplier[31]}] [get_ports {shifted_mplier[30]}] [get_ports              \
{shifted_mplier[29]}] [get_ports {shifted_mplier[28]}] [get_ports              \
{shifted_mplier[27]}] [get_ports {shifted_mplier[26]}] [get_ports              \
{shifted_mplier[25]}] [get_ports {shifted_mplier[24]}] [get_ports              \
{shifted_mplier[23]}] [get_ports {shifted_mplier[22]}] [get_ports              \
{shifted_mplier[21]}] [get_ports {shifted_mplier[20]}] [get_ports              \
{shifted_mplier[19]}] [get_ports {shifted_mplier[18]}] [get_ports              \
{shifted_mplier[17]}] [get_ports {shifted_mplier[16]}] [get_ports              \
{shifted_mplier[15]}] [get_ports {shifted_mplier[14]}] [get_ports              \
{shifted_mplier[13]}] [get_ports {shifted_mplier[12]}] [get_ports              \
{shifted_mplier[11]}] [get_ports {shifted_mplier[10]}] [get_ports              \
{shifted_mplier[9]}] [get_ports {shifted_mplier[8]}] [get_ports                \
{shifted_mplier[7]}] [get_ports {shifted_mplier[6]}] [get_ports                \
{shifted_mplier[5]}] [get_ports {shifted_mplier[4]}] [get_ports                \
{shifted_mplier[3]}] [get_ports {shifted_mplier[2]}] [get_ports                \
{shifted_mplier[1]}] [get_ports {shifted_mplier[0]}] [get_ports                \
{shifted_mcand[63]}] [get_ports {shifted_mcand[62]}] [get_ports                \
{shifted_mcand[61]}] [get_ports {shifted_mcand[60]}] [get_ports                \
{shifted_mcand[59]}] [get_ports {shifted_mcand[58]}] [get_ports                \
{shifted_mcand[57]}] [get_ports {shifted_mcand[56]}] [get_ports                \
{shifted_mcand[55]}] [get_ports {shifted_mcand[54]}] [get_ports                \
{shifted_mcand[53]}] [get_ports {shifted_mcand[52]}] [get_ports                \
{shifted_mcand[51]}] [get_ports {shifted_mcand[50]}] [get_ports                \
{shifted_mcand[49]}] [get_ports {shifted_mcand[48]}] [get_ports                \
{shifted_mcand[47]}] [get_ports {shifted_mcand[46]}] [get_ports                \
{shifted_mcand[45]}] [get_ports {shifted_mcand[44]}] [get_ports                \
{shifted_mcand[43]}] [get_ports {shifted_mcand[42]}] [get_ports                \
{shifted_mcand[41]}] [get_ports {shifted_mcand[40]}] [get_ports                \
{shifted_mcand[39]}] [get_ports {shifted_mcand[38]}] [get_ports                \
{shifted_mcand[37]}] [get_ports {shifted_mcand[36]}] [get_ports                \
{shifted_mcand[35]}] [get_ports {shifted_mcand[34]}] [get_ports                \
{shifted_mcand[33]}] [get_ports {shifted_mcand[32]}] [get_ports                \
{shifted_mcand[31]}] [get_ports {shifted_mcand[30]}] [get_ports                \
{shifted_mcand[29]}] [get_ports {shifted_mcand[28]}] [get_ports                \
{shifted_mcand[27]}] [get_ports {shifted_mcand[26]}] [get_ports                \
{shifted_mcand[25]}] [get_ports {shifted_mcand[24]}] [get_ports                \
{shifted_mcand[23]}] [get_ports {shifted_mcand[22]}] [get_ports                \
{shifted_mcand[21]}] [get_ports {shifted_mcand[20]}] [get_ports                \
{shifted_mcand[19]}] [get_ports {shifted_mcand[18]}] [get_ports                \
{shifted_mcand[17]}] [get_ports {shifted_mcand[16]}] [get_ports                \
{shifted_mcand[15]}] [get_ports {shifted_mcand[14]}] [get_ports                \
{shifted_mcand[13]}] [get_ports {shifted_mcand[12]}] [get_ports                \
{shifted_mcand[11]}] [get_ports {shifted_mcand[10]}] [get_ports                \
{shifted_mcand[9]}] [get_ports {shifted_mcand[8]}] [get_ports                  \
{shifted_mcand[7]}] [get_ports {shifted_mcand[6]}] [get_ports                  \
{shifted_mcand[5]}] [get_ports {shifted_mcand[4]}] [get_ports                  \
{shifted_mcand[3]}] [get_ports {shifted_mcand[2]}] [get_ports                  \
{shifted_mcand[1]}] [get_ports {shifted_mcand[0]}]]
