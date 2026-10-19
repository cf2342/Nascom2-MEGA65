library ieee;
use ieee.std_logic_1164.all;

package vfat_name_pkg is
  constant VFAT_DISPLAY_CHARS : positive := 28;
  subtype vfat_display_name_t is
    std_logic_vector(VFAT_DISPLAY_CHARS*8-1 downto 0);
  type vfat_display_name_array_t is
    array (natural range <>) of vfat_display_name_t;
end package;

package body vfat_name_pkg is
end package body;
