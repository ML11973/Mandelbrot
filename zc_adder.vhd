--------------------------------------------------------------------------------
--
-- File     : zc_adder.vhd
-- Author   : Marc Leemann
-- Date     : 03.05.2022
--
-- Context  : Project name
--
--------------------------------------------------------------------------------
-- Description :
--
--
--------------------------------------------------------------------------------
-- Dependencies :
--
--------------------------------------------------------------------------------
-- Modifications :
-- Ver   Date        Person     Comments
-- 1.0   03.05.2022  MLN  Initial version
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity zc_adder is
    generic (
        SIZE : integer := 18;
        FIXEDPOINT : integer := 4
    );
    port (
        --clk_i     : in std_logic;
        --rst_i     : in std_logic;
        z_real_i      : in std_logic_vector(SIZE-1 downto 0);
        z_imag_i      : in std_logic_vector(SIZE-1 downto 0);
        c_real_i      : in std_logic_vector(SIZE-1 downto 0);
        c_imag_i      : in std_logic_vector(SIZE-1 downto 0);
        z_next_real_o : out std_logic_vector(SIZE-1 downto 0);
        z_next_imag_o : out std_logic_vector(SIZE-1 downto 0)
    );
end zc_adder;
architecture dataflow of zc_adder is

    signal z_real_sq_big_s         : std_logic_vector((2*SIZE-1) downto 0);
    signal z_imag_sq_big_s         : std_logic_vector((2*SIZE-1) downto 0);
    signal z_real_imag_mult_big_s  : std_logic_vector((2*SIZE-1) downto 0);

    signal z_real_sq_s        : std_logic_vector(SIZE-1 downto 0);
    signal z_imag_sq_s        : std_logic_vector(SIZE-1 downto 0);
    signal z_real_imag_mult_s : std_logic_vector(SIZE-1 downto 0);


begin
  -- Original formulas:
  -- R(Znext) = R(z)^2 - I(z)^2 + R(c)
  -- I(Znext) = 2*R(z)*I(z) + I(c)

  z_real_sq_big_s         <= (z_real_i * z_real_i);
  z_imag_sq_big_s         <= (z_imag_i * z_imag_i);
  z_real_imag_mult_big_s  <= (z_real_i * z_imag_i);

  z_real_sq_s <= z_real_sq_big_s((SIZE+FIXEDPOINT-1) downto FIXEDPOINT);
  z_imag_sq_s <= z_imag_sq_big_s((SIZE+FIXEDPOINT-1) downto FIXEDPOINT);

  z_real_imag_mult_s <= z_real_imag_mult_big_s((SIZE+FIXEDPOINT) downto FIXEDPOINT+1); -- cross-product is multiplied by 2 by bit-shift

  z_next_real_o <= c_real_i + z_real_sq_s - z_imag_sq_s;
  z_next_imag_o <= c_imag_i + z_real_imag_mult_s;

end dataflow;
