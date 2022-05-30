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

  type z_t is record
    -- Pipeline data
    z_real  : signed(DSP_WIDTH-1 downto 0);
    z_imag  : signed(DSP_WIDTH-1 downto 0);

    cnt     : natural range 0 to MAX_ITER;
  end record;

  type mem_t is record
    addr    : std_logic_vector(2*COORD_WIDTH-1 downto 0);
    data    : std_logic_vector(MEM_WIDTH-1 downto 0);
    we      : std_logic;
  end record;

  type coords_t is record
    -- Feed from coordinate generator
    c_real  : signed(DSP_WIDTH  -1 downto 0);
    c_imag  : signed(DSP_WIDTH  -1 downto 0);
    x       : std_logic_vector(COORD_WIDTH-1 downto 0);
    y       : std_logic_vector(COORD_WIDTH-1 downto 0);
    -- Pipeline control signal
    index : std_logic;
  end record;

end package;
