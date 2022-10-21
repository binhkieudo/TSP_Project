set core [ipx::current_core]

set_property core_revision 2 $core
foreach up [ipx::get_user_parameters] {
  ipx::remove_user_parameter [get_property NAME $up] $core
}
ipx::associate_bus_interfaces -busif m00_axi_gmem -clock ap_clk $core
ipx::associate_bus_interfaces -busif m01_axi_gmem -clock ap_clk $core
ipx::associate_bus_interfaces -busif m02_axi_gmem -clock ap_clk $core
ipx::associate_bus_interfaces -busif m03_axi_gmem -clock ap_clk $core
ipx::associate_bus_interfaces -busif m04_axi_gmem -clock ap_clk $core
ipx::associate_bus_interfaces -busif m05_axi_gmem -clock ap_clk $core
ipx::associate_bus_interfaces -busif m06_axi_gmem -clock ap_clk $core
ipx::associate_bus_interfaces -busif m07_axi_gmem -clock ap_clk $core
ipx::associate_bus_interfaces -busif m08_axi_gmem -clock ap_clk $core
ipx::associate_bus_interfaces -busif m09_axi_gmem -clock ap_clk $core
ipx::associate_bus_interfaces -busif m10_axi_gmem -clock ap_clk $core
ipx::associate_bus_interfaces -busif m11_axi_gmem -clock ap_clk $core
ipx::associate_bus_interfaces -busif m12_axi_gmem -clock ap_clk $core
ipx::associate_bus_interfaces -busif m13_axi_gmem -clock ap_clk $core
ipx::associate_bus_interfaces -busif m14_axi_gmem -clock ap_clk $core
ipx::associate_bus_interfaces -busif m15_axi_gmem -clock ap_clk $core
ipx::associate_bus_interfaces -busif m16_axi_gmem -clock ap_clk $core
ipx::associate_bus_interfaces -busif m17_axi_gmem -clock ap_clk $core
ipx::associate_bus_interfaces -busif m18_axi_gmem -clock ap_clk $core
ipx::associate_bus_interfaces -busif m19_axi_gmem -clock ap_clk $core
ipx::associate_bus_interfaces -busif m20_axi_gmem -clock ap_clk $core
ipx::associate_bus_interfaces -busif m21_axi_gmem -clock ap_clk $core
ipx::associate_bus_interfaces -busif m22_axi_gmem -clock ap_clk $core
ipx::associate_bus_interfaces -busif m23_axi_gmem -clock ap_clk $core
ipx::associate_bus_interfaces -busif m24_axi_gmem -clock ap_clk $core
ipx::associate_bus_interfaces -busif m25_axi_gmem -clock ap_clk $core
ipx::associate_bus_interfaces -busif m26_axi_gmem -clock ap_clk $core
ipx::associate_bus_interfaces -busif m27_axi_gmem -clock ap_clk $core
ipx::associate_bus_interfaces -busif m28_axi_gmem -clock ap_clk $core
ipx::associate_bus_interfaces -busif m29_axi_gmem -clock ap_clk $core
ipx::associate_bus_interfaces -busif m30_axi_gmem -clock ap_clk $core
ipx::associate_bus_interfaces -busif m31_axi_gmem -clock ap_clk $core
ipx::associate_bus_interfaces -busif s_axi_control -clock ap_clk $core

set mem_map    [::ipx::add_memory_map -quiet "s_axi_control" $core]
set addr_block [::ipx::add_address_block -quiet "reg0" $mem_map]

set reg      [::ipx::add_register "CTRL" $addr_block]
  set_property description    "Control signals"    $reg
  set_property address_offset 0x000 $reg
  set_property size           32    $reg

set reg      [::ipx::add_register "GIER" $addr_block]
  set_property description    "Global Interrupt Enable Register"    $reg
  set_property address_offset 0x004 $reg
  set_property size           32    $reg

set reg      [::ipx::add_register "IP_IER" $addr_block]
  set_property description    "IP Interrupt Enable Register"    $reg
  set_property address_offset 0x008 $reg
  set_property size           32    $reg

set reg      [::ipx::add_register "IP_ISR" $addr_block]
  set_property description    "IP Interrupt Status Register"    $reg
  set_property address_offset 0x00C $reg
  set_property size           32    $reg

set reg      [::ipx::add_register "DEVCTRL" $addr_block]
  set_property description    "Device control signals"    $reg
  set_property address_offset 0x14c $reg
  set_property size           32    $reg

set reg      [::ipx::add_register "KEYLEN" $addr_block]
  set_property description    "Key length"    $reg
  set_property address_offset 0x150 $reg
  set_property size           32    $reg

set reg      [::ipx::add_register "KEY" $addr_block]
  set_property description    "Key"    $reg
  set_property address_offset 0x154 $reg
  set_property size           32    $reg

set reg      [::ipx::add_register -quiet "channel0" $addr_block]
  set_property address_offset 0x010 $reg
  set_property size           64   $reg
  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] 
  set_property value m00_axi_gmem $regparam 

set reg      [::ipx::add_register -quiet "channel1" $addr_block]
  set_property address_offset 0x018 $reg
  set_property size           64   $reg
  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] 
  set_property value m01_axi_gmem $regparam 

set reg      [::ipx::add_register -quiet "channel2" $addr_block]
  set_property address_offset 0x020 $reg
  set_property size           64   $reg
  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] 
  set_property value m02_axi_gmem $regparam 

set reg      [::ipx::add_register -quiet "channel3" $addr_block]
  set_property address_offset 0x028 $reg
  set_property size           64   $reg
  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] 
  set_property value m03_axi_gmem $regparam 

set reg      [::ipx::add_register -quiet "channel4" $addr_block]
  set_property address_offset 0x030 $reg
  set_property size           64   $reg
  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] 
  set_property value m04_axi_gmem $regparam 

set reg      [::ipx::add_register -quiet "channel5" $addr_block]
  set_property address_offset 0x038 $reg
  set_property size           64   $reg
  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] 
  set_property value m05_axi_gmem $regparam 

set reg      [::ipx::add_register -quiet "channel6" $addr_block]
  set_property address_offset 0x040 $reg
  set_property size           64   $reg
  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] 
  set_property value m06_axi_gmem $regparam 

set reg      [::ipx::add_register -quiet "channel7" $addr_block]
  set_property address_offset 0x048 $reg
  set_property size           64   $reg
  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] 
  set_property value m07_axi_gmem $regparam 

set reg      [::ipx::add_register -quiet "channel8" $addr_block]
  set_property address_offset 0x050 $reg
  set_property size           64   $reg
  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] 
  set_property value m08_axi_gmem $regparam 

set reg      [::ipx::add_register -quiet "channel9" $addr_block]
  set_property address_offset 0x058 $reg
  set_property size           64   $reg
  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] 
  set_property value m09_axi_gmem $regparam 

set reg      [::ipx::add_register -quiet "channel10" $addr_block]
  set_property address_offset 0x060 $reg
  set_property size           64   $reg
  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] 
  set_property value m10_axi_gmem $regparam 

set reg      [::ipx::add_register -quiet "channel11" $addr_block]
  set_property address_offset 0x068 $reg
  set_property size           64   $reg
  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] 
  set_property value m11_axi_gmem $regparam 

set reg      [::ipx::add_register -quiet "channel12" $addr_block]
  set_property address_offset 0x070 $reg
  set_property size           64   $reg
  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] 
  set_property value m12_axi_gmem $regparam 

set reg      [::ipx::add_register -quiet "channel13" $addr_block]
  set_property address_offset 0x078 $reg
  set_property size           64   $reg
  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] 
  set_property value m13_axi_gmem $regparam 

set reg      [::ipx::add_register -quiet "channel14" $addr_block]
  set_property address_offset 0x080 $reg
  set_property size           64   $reg
  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] 
  set_property value m14_axi_gmem $regparam 

set reg      [::ipx::add_register -quiet "channel15" $addr_block]
  set_property address_offset 0x088 $reg
  set_property size           64   $reg
  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] 
  set_property value m15_axi_gmem $regparam 

set reg      [::ipx::add_register -quiet "channel16" $addr_block]
  set_property address_offset 0x090 $reg
  set_property size           64   $reg
  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] 
  set_property value m16_axi_gmem $regparam 

set reg      [::ipx::add_register -quiet "channel17" $addr_block]
  set_property address_offset 0x098 $reg
  set_property size           64   $reg
  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] 
  set_property value m17_axi_gmem $regparam 

set reg      [::ipx::add_register -quiet "channel18" $addr_block]
  set_property address_offset 0x0a0 $reg
  set_property size           64   $reg
  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] 
  set_property value m18_axi_gmem $regparam 

set reg      [::ipx::add_register -quiet "channel19" $addr_block]
  set_property address_offset 0x0a8 $reg
  set_property size           64   $reg
  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] 
  set_property value m19_axi_gmem $regparam 

set reg      [::ipx::add_register -quiet "channel20" $addr_block]
  set_property address_offset 0x0b0 $reg
  set_property size           64   $reg
  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] 
  set_property value m20_axi_gmem $regparam 

set reg      [::ipx::add_register -quiet "channel21" $addr_block]
  set_property address_offset 0x0b8 $reg
  set_property size           64   $reg
  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] 
  set_property value m21_axi_gmem $regparam 

set reg      [::ipx::add_register -quiet "channel22" $addr_block]
  set_property address_offset 0x0c0 $reg
  set_property size           64   $reg
  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] 
  set_property value m22_axi_gmem $regparam 

set reg      [::ipx::add_register -quiet "channel23" $addr_block]
  set_property address_offset 0x0c8 $reg
  set_property size           64   $reg
  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] 
  set_property value m23_axi_gmem $regparam 

set reg      [::ipx::add_register -quiet "channel24" $addr_block]
  set_property address_offset 0x0d0 $reg
  set_property size           64   $reg
  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] 
  set_property value m24_axi_gmem $regparam 

set reg      [::ipx::add_register -quiet "channel25" $addr_block]
  set_property address_offset 0x0d8 $reg
  set_property size           64   $reg
  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] 
  set_property value m25_axi_gmem $regparam 

set reg      [::ipx::add_register -quiet "channel26" $addr_block]
  set_property address_offset 0x0e0 $reg
  set_property size           64   $reg
  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] 
  set_property value m26_axi_gmem $regparam 

set reg      [::ipx::add_register -quiet "channel27" $addr_block]
  set_property address_offset 0x0e8 $reg
  set_property size           64   $reg
  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] 
  set_property value m27_axi_gmem $regparam 

set reg      [::ipx::add_register -quiet "channel28" $addr_block]
  set_property address_offset 0x0f0 $reg
  set_property size           64   $reg
  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] 
  set_property value m28_axi_gmem $regparam 

set reg      [::ipx::add_register -quiet "channel29" $addr_block]
  set_property address_offset 0x0f8 $reg
  set_property size           64   $reg
  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] 
  set_property value m29_axi_gmem $regparam 

set reg      [::ipx::add_register -quiet "channel30" $addr_block]
  set_property address_offset 0x100 $reg
  set_property size           64   $reg
  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] 
  set_property value m30_axi_gmem $regparam 

set reg      [::ipx::add_register -quiet "channel31" $addr_block]
  set_property address_offset 0x108 $reg
  set_property size           64   $reg
  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] 
  set_property value m31_axi_gmem $regparam 

set reg      [::ipx::add_register -quiet "start_address" $addr_block]
  set_property address_offset 0x110 $reg
  set_property size           64   $reg

set reg      [::ipx::add_register -quiet "file_size" $addr_block]
  set_property address_offset 0x118 $reg
  set_property size           64   $reg

set reg      [::ipx::add_register -quiet "result" $addr_block]
  set_property address_offset 0x120 $reg
  set_property size           32   $reg

set reg      [::ipx::add_register -quiet "match_count" $addr_block]
  set_property address_offset 0x124 $reg
  set_property size           32   $reg

set reg      [::ipx::add_register -quiet "bitstream" $addr_block]
  set_property address_offset 0x128 $reg
  set_property size           64   $reg

set reg      [::ipx::add_register -quiet "bashcode" $addr_block]
  set_property address_offset 0x130 $reg
  set_property size           32   $reg

set reg      [::ipx::add_register -quiet "next_address" $addr_block]
  set_property address_offset 0x134 $reg
  set_property size           64   $reg

set reg      [::ipx::add_register -quiet "next_file_size" $addr_block]
  set_property address_offset 0x13c $reg
  set_property size           64   $reg

set reg      [::ipx::add_register -quiet "bash_offset" $addr_block]
  set_property address_offset 0x144 $reg
  set_property size           64   $reg

set reg      [::ipx::add_register -quiet "DEBUG0" $addr_block]
  set_property address_offset 0x158 $reg
  set_property size           32   $reg

set reg      [::ipx::add_register -quiet "DEBUG1" $addr_block]
  set_property address_offset 0x15c $reg
  set_property size           32   $reg

set reg      [::ipx::add_register -quiet "DEBUG2" $addr_block]
  set_property address_offset 0x160 $reg
  set_property size           32   $reg

set reg      [::ipx::add_register -quiet "DEBUG3" $addr_block]
  set_property address_offset 0x164 $reg
  set_property size           32   $reg

set_property slave_memory_map_ref "s_axi_control" [::ipx::get_bus_interfaces -of $core "s_axi_control"]

set_property xpm_libraries {XPM_CDC XPM_MEMORY XPM_FIFO} $core
set_property sdx_kernel true $core
set_property sdx_kernel_type rtl $core
ipx::create_xgui_files $core
ipx::update_checksums $core
ipx::check_integrity -kernel $core
ipx::save_core $core
