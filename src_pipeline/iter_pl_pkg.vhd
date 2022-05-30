--------------------------------------------------------------------------------
--
-- File     : iter_pl_pkg.vhd
-- Author   : Marc Leemann
-- Date     : 23.05.2022
--
-- Context  : Mandelbrot project
--
--------------------------------------------------------------------------------
-- Description :
--  Package with type records for iterator pipeline implementation
--------------------------------------------------------------------------------
-- Dependencies :
--
--------------------------------------------------------------------------------
-- Modifications :
-- Ver   Date        Person     Comments
-- 1.0   23.05.2022  MLN        Initial version
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package iter_pl_pkg is
  constant DSP_WIDTH    : integer := 18;
  constant N_DECIMALS   : integer := 14;
  constant R_SQ         : integer := 4;
  constant MAX_ITER     : integer := 100;
  constant COORD_WIDTH  : integer := 10;
  constant MEM_WIDTH    : integer := 9;

  type iter_zc_out_t is record
    -- Pipeline control signal
    addr_pl : std_logic;
    -- Pipeline data
    z_real  : std_logic_vector(DSP_WIDTH-1 downto 0);
    z_imag  : std_logic_vector(DSP_WIDTH-1 downto 0);
    c_real  : std_logic_vector(DSP_WIDTH-1 downto 0);
    c_imag  : std_logic_vector(DSP_WIDTH-1 downto 0);
  end record;

  type iter_mem_out_t is record
    addr    : std_logic_vector(2*COORD_WIDTH-1 downto 0);
    data    : std_logic_vector(MEM_WIDTH-1 downto 0);
    we      : std_logic;

  end record;

  type iter_zc_in_t is record
    -- Pipeline control signal
    addr_pl : std_logic;
    -- Data
    z_next_real : std_logic_vector(DSP_WIDTH-1 downto 0);
    z_next_imag : std_logic_vector(DSP_WIDTH-1 downto 0);
    z_greater_r : std_logic;
  end record;

  type iter_compgen_in_t is record
    -- Feed from coordinate generator
    c_real  : std_logic_vector(DSP_WIDTH  -1 downto 0);
    c_imag  : std_logic_vector(DSP_WIDTH  -1 downto 0);
    x       : std_logic_vector(COORD_WIDTH-1 downto 0);
    y       : std_logic_vector(COORD_WIDTH-1 downto 0);
  end record;

  type iterator_outputs_t is record
    -- Complex value generator control signal
    nextval : std_logic;
    -- ZC adder signals
    zc : iter_zc_out_t;
    -- Memory signals
    mem : iter_mem_out_t;
  end record;

  type iterator_inputs_t is record
    -- Complex value generator
    cv : iter_compgen_in_t;
    -- ZC adder signals
    zc : iter_zc_in_t;


  end record;
end package;
