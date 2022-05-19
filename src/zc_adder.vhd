--------------------------------------------------------------------------------
--
-- File     : zc_adder.vhd
-- Author   : Marc Leemann
-- Date     : 03.05.2022
--
-- Context  : Mandelbrot project
--
--------------------------------------------------------------------------------
-- Description :
--  Full combinatory implementation of
--  R(Znext) = R(z)^2 - I(z)^2 + R(c)
--  I(Znext) = 2*R(z)*I(z) + I(c)
--
--  To use for Mandelbrot series computing with an iterator
--------------------------------------------------------------------------------
-- Dependencies :
--
--------------------------------------------------------------------------------
-- Modifications :
-- Ver   Date        Person     Comments
-- 1.0   03.05.2022  MLN        Initial version
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity zc_adder is
    generic (
        SIZE : integer := 18;
        FIXEDPOINT : integer := 14;
        R_SQ : integer := 4
    );
    port (
        --clk_i     : in std_logic;
        --rst_i     : in std_logic;
        z_real_i      : in std_logic_vector(SIZE-1 downto 0);
        z_imag_i      : in std_logic_vector(SIZE-1 downto 0);
        c_real_i      : in std_logic_vector(SIZE-1 downto 0);
        c_imag_i      : in std_logic_vector(SIZE-1 downto 0);
        z_next_real_o : out std_logic_vector(SIZE-1 downto 0);
        z_next_imag_o : out std_logic_vector(SIZE-1 downto 0);
        z_greater_r_o : out std_logic
    );
end zc_adder;
architecture dataflow of zc_adder is

    -- Inputs as signed
    signal z_real_s                 : signed(SIZE-1 downto 0);
    signal z_imag_s                 : signed(SIZE-1 downto 0);
    signal c_real_s                 : signed(SIZE-1 downto 0);
    signal c_imag_s                 : signed(SIZE-1 downto 0);

    -- Intermediate numbers
    signal z_real_sq_big_s          : signed(2*SIZE-1 downto 0);
    signal z_imag_sq_big_s          : signed(2*SIZE-1 downto 0);
    signal z_real_imag_mult_big_s   : signed(2*SIZE-1 downto 0);

    signal z_real_sq_s              : signed(SIZE-1 downto 0);
    signal z_imag_sq_s              : signed(SIZE-1 downto 0);
    signal z_real_imag_mult_s       : signed(SIZE-1 downto 0);


    signal z_next_real_s            : signed(SIZE-1 downto 0);
    signal z_next_imag_s            : signed(SIZE-1 downto 0);
    signal z_next_real_sq_s         : signed(SIZE-1 downto 0);
    signal z_next_imag_sq_s         : signed(SIZE-1 downto 0);
    signal z_next_real_sq_big_s     : signed(2*SIZE-1 downto 0);
    signal z_next_imag_sq_big_s     : signed(2*SIZE-1 downto 0);

    signal z_rsq_s                  : signed(SIZE-1 downto 0);


begin

  -- Pipeline locations indicated as PIPELINE
  -- TODO synth and check proper DSP usage -> RTL view

    z_real_s <= signed(z_real_i);
    z_imag_s <= signed(z_imag_i);
    c_real_s <= signed(c_real_i);
    c_imag_s <= signed(c_imag_i);

    -- Original formulas:
    -- R(Znext) = R(z)^2 - I(z)^2 + R(c)
    -- I(Znext) = 2*R(z)*I(z) + I(c)

    z_real_sq_big_s         <= (z_real_s * z_real_s);
    z_imag_sq_big_s         <= (z_imag_s * z_imag_s);
    z_real_imag_mult_big_s  <= (z_real_s * z_imag_s);

    --PIPELINE-----------------------------------------------------------------

    -- Example: Size = 18, FIXEDPOINT = 14, D -> decimal, I -> integer, S -> sign
    -- z_real_sq_big(35 downto 0)   -> z_real_sq((18+4-1) downto 4)
    -- z_real_sq_big: SI-7x--I.D------------28x-----------D
    -- z_real_sq:     SXXXXIII.D----14x-----DXXXXXXXXXXXXXX
    --                35   30               14            0
    z_real_sq_s <=  z_real_sq_big_s(2*SIZE-1) & -- sign bit
                    z_real_sq_big_s((FIXEDPOINT+SIZE-2) downto FIXEDPOINT);
    z_imag_sq_s <=  z_imag_sq_big_s(2*SIZE-1) & -- sign bit
                    z_imag_sq_big_s((FIXEDPOINT+SIZE-2) downto FIXEDPOINT);

    z_real_imag_mult_s <= z_real_imag_mult_big_s(2*SIZE-1) & --sign bit
                z_real_imag_mult_big_s((SIZE+FIXEDPOINT-3) downto FIXEDPOINT-1); -- cross-product is multiplied by 2 by bit-shift

    --PIPELINE-----------------------------------------------------------------

    z_next_real_s <= c_real_s + z_real_sq_s - z_imag_sq_s;
    z_next_imag_s <= c_imag_s + z_real_imag_mult_s;

    --PIPELINE-----------------------------------------------------------------

    -- Computing znext radius
    z_next_real_sq_big_s  <= (z_next_real_s * z_next_real_s);
    z_next_imag_sq_big_s  <= (z_next_imag_s * z_next_imag_s);

    z_next_real_sq_s <= z_next_real_sq_big_s(2*SIZE-1) & -- sign bit
                        z_next_real_sq_big_s((FIXEDPOINT+SIZE-2) downto FIXEDPOINT);

    z_next_imag_sq_s <= z_next_imag_sq_big_s(2*SIZE-1) & -- sign bit
                        z_next_imag_sq_big_s((FIXEDPOINT+SIZE-2) downto FIXEDPOINT);

    z_next_real_o <= std_logic_vector(z_next_real_s);
    z_next_imag_o <= std_logic_vector(z_next_imag_s);

    --PIPELINE-----------------------------------------------------------------
    z_rsq_s <= z_next_real_sq_s + z_next_imag_sq_s;

    --PIPELINE-----------------------------------------------------------------
    -- Radius compare
    rcomp : process (all) is
    begin
      -- Signal init
      z_greater_r_o <= '0';
      -- only compare integer part of z_rsq_s
      -- converges if MAX_ITER is reached
      if to_integer(z_rsq_s(SIZE-1 downto FIXEDPOINT)) >= R_SQ then
        z_greater_r_o <= '1';
      end if;
    end process;


    -- Precision could be improved by truncating only the last output
    -- This would imply non-standard DSPs or all operations to be 36-bit signed



end dataflow;
