--------------------------------------------------------------------------------
-- video_out_clock.vhd                                                        --
-- Pixel and serialiser clock synthesiser (dynamically configured MMCM).      --
--------------------------------------------------------------------------------
-- (C) Copyright 2022 Adam Barnes <ambarnes@gmail.com>                        --
-- This file is part of The Tyto Project. The Tyto Project is free software:  --
-- you can redistribute it and/or modify it under the terms of the GNU Lesser --
-- General Public License as published by the Free Software Foundation,       --
-- either version 3 of the License, or (at your option) any later version.    --
-- The Tyto Project is distributed in the hope that it will be useful, but    --
-- WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY --
-- or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public     --
-- License for more details. You should have received a copy of the GNU       --
-- Lesser General Public License along with The Tyto Project. If not, see     --
-- https://www.gnu.org/licenses/.                                             --
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

PACKAGE video_out_clock_pkg IS

  COMPONENT video_out_clock IS
    GENERIC (
      fref : real
    );
    PORT (

      rsti : IN STD_LOGIC;
      clki : IN STD_LOGIC;
      sel : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      rsto : OUT STD_LOGIC;
      clko : OUT STD_LOGIC;
      clko_x5 : OUT STD_LOGIC

    );
  END COMPONENT video_out_clock;

END PACKAGE video_out_clock_pkg;

----------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

LIBRARY unisim;
USE unisim.vcomponents.ALL;

ENTITY video_out_clock IS
  GENERIC (
    fref : real -- reference clock frequency (MHz) (typically 100.0)
  );
  PORT (

    rsti : IN STD_LOGIC; -- input (reference) clock synchronous reset
    clki : IN STD_LOGIC; -- input (reference) clock
    sel : IN STD_LOGIC_VECTOR(1 DOWNTO 0); -- output clock select: 00 = 25.2, 01 = 27.0, 10 = 74.25, 11 = 148.5
    rsto : OUT STD_LOGIC; -- output clock synchronous reset
    clko : OUT STD_LOGIC; -- pixel clock
    clko_x5 : OUT STD_LOGIC -- serialiser clock (5x pixel clock)

  );
END ENTITY video_out_clock;

ARCHITECTURE synth OF video_out_clock IS

  SIGNAL mmcm_rst : STD_LOGIC; -- MMCM reset
  SIGNAL locked : STD_LOGIC; -- MMCM locked output

  SIGNAL clk_fb : STD_LOGIC; -- feedback clock
  SIGNAL clku_fb : STD_LOGIC; -- unbuffered feedback clock
  SIGNAL clko_u : STD_LOGIC; -- unbuffered pixel clock
  SIGNAL clko_b : STD_LOGIC; -- buffered pixel clock
  SIGNAL clko_u_x5 : STD_LOGIC; -- unbuffered serializer clock
  SIGNAL rsto_pipe : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '1');

BEGIN

  -- The design is fixed to 800x600p60, so the old DRP/MMCM reconfiguration
  -- machinery is intentionally removed. The `sel` port remains only to preserve
  -- the existing interface.
  mmcm_rst <= rsti;

  -- For 100 MHz reference clock:
  --   fVCO     = 100 MHz * 8 / 1 = 800 MHz
  --   clko_x5  = 800 MHz / 4  = 200 MHz
  --   clko     = 800 MHz / 20 = 40 MHz
  MMCM : COMPONENT mmcme2_adv
    GENERIC MAP(
      bandwidth => "OPTIMIZED",
      clkfbout_mult_f => 8.0,
      clkfbout_phase => 0.0,
      clkfbout_use_fine_ps => false,
      clkin1_period => 10.0,
      clkin2_period => 0.0,
      clkout0_divide_f => 4.0,
      clkout0_duty_cycle => 0.5,
      clkout0_phase => 0.0,
      clkout0_use_fine_ps => false,
      clkout1_divide => 20,
      clkout1_duty_cycle => 0.5,
      clkout1_phase => 0.0,
      clkout1_use_fine_ps => false,
      clkout2_divide => 1,
      clkout2_duty_cycle => 0.5,
      clkout2_phase => 0.0,
      clkout2_use_fine_ps => false,
      clkout3_divide => 1,
      clkout3_duty_cycle => 0.5,
      clkout3_phase => 0.0,
      clkout3_use_fine_ps => false,
      clkout4_cascade => false,
      clkout4_divide => 1,
      clkout4_duty_cycle => 0.5,
      clkout4_phase => 0.0,
      clkout4_use_fine_ps => false,
      clkout5_divide => 1,
      clkout5_duty_cycle => 0.5,
      clkout5_phase => 0.0,
      clkout5_use_fine_ps => false,
      clkout6_divide => 1,
      clkout6_duty_cycle => 0.5,
      clkout6_phase => 0.0,
      clkout6_use_fine_ps => false,
      compensation => "ZHOLD",
      divclk_divide => 1,
      is_clkinsel_inverted => '0',
      is_psen_inverted => '0',
      is_psincdec_inverted => '0',
      is_pwrdwn_inverted => '0',
      is_rst_inverted => '0',
      ref_jitter1 => 0.01,
      ref_jitter2 => 0.01,
      ss_en => "FALSE",
      ss_mode => "CENTER_HIGH",
      ss_mod_period => 10000,
      startup_wait => false
    )
    PORT MAP(
      pwrdwn => '0',
      rst => mmcm_rst,
      locked => locked,
      clkin1 => clki,
      clkin2 => '0',
      clkinsel => '1',
      clkinstopped => OPEN,
      clkfbin => clk_fb,
      clkfbout => clku_fb,
      clkfboutb => OPEN,
      clkfbstopped => OPEN,
      clkout0 => clko_u_x5,
      clkout0b => OPEN,
      clkout1 => clko_u,
      clkout1b => OPEN,
      clkout2 => OPEN,
      clkout2b => OPEN,
      clkout3 => OPEN,
      clkout3b => OPEN,
      clkout4 => OPEN,
      clkout5 => OPEN,
      clkout6 => OPEN,
      dclk => '0',
      daddr => (OTHERS => '0'),
      den => '0',
      dwe => '0',
      di => (OTHERS => '0'),
      do => OPEN,
      drdy => OPEN,
      psclk => '0',
      psdone => OPEN,
      psen => '0',
      psincdec => '0'
    );

  U_BUFG_0 : COMPONENT bufg
    PORT MAP(
      i => clko_u_x5,
      o => clko_x5
    );

  U_BUFG_1 : COMPONENT bufg
    PORT MAP(
      i => clko_u,
      o => clko_b
    );

  U_BUFG_F : COMPONENT bufg
    PORT MAP(
      i => clku_fb,
      o => clk_fb
    );

  DO_RST_SYNC : PROCESS (clko_b) IS
  BEGIN
    IF rising_edge(clko_b) THEN
      IF rsti = '1' OR locked = '0' THEN
        rsto_pipe <= (OTHERS => '1');
      ELSE
        rsto_pipe <= rsto_pipe(0) & '0';
      END IF;
    END IF;
  END PROCESS DO_RST_SYNC;

  rsto <= rsto_pipe(1);
  clko <= clko_b;

END ARCHITECTURE synth;
