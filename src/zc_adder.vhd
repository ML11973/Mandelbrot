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
-- 1.0   03.05.2022  MLN  Initial version
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
    signal z_real_sq_big_s          : signed((2*SIZE-1) downto 0);
    signal z_imag_sq_big_s          : signed((2*SIZE-1) downto 0);
    signal z_real_imag_mult_big_s   : signed((2*SIZE-1) downto 0);

    signal z_real_sq_s              : signed(SIZE-1 downto 0);
    signal z_imag_sq_s              : signed(SIZE-1 downto 0);
    signal z_real_imag_mult_s       : signed(SIZE-1 downto 0);

    signal z_radius_s               : signed(SIZE-1 downto 0);


begin

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

    -- Example: Size = 18, FIXEDPOINT = 4, D -> decimal, I -> integer, S -> sign
    -- z_real_sq_big(35 downto 0)   -> z_real_sq((18+4-1) downto 4)
    -- z_real_sq_big: SI-----------24x------------I.D---8--D
    -- z_real_sq:     SXXXXXXXXXXXXXXXI-----13----I.DDDDXXXX

    z_real_sq_s <=  z_real_sq_big_s(2*SIZE-1) & -- sign bit
                    z_real_sq_big_s((SIZE-2 + FIXEDPOINT) downto FIXEDPOINT);
    z_imag_sq_s <=  z_imag_sq_big_s(2*SIZE-1) & -- sign bit
                    z_imag_sq_big_s((SIZE-2 + FIXEDPOINT) downto FIXEDPOINT);

    z_real_imag_mult_s <= z_real_imag_mult_big_s(2*SIZE-1) & --sign bit
                z_real_imag_mult_big_s((SIZE+FIXEDPOINT-1) downto FIXEDPOINT+1); -- cross-product is multiplied by 2 by bit-shift
                -- TODO check 2-multiplication

    z_radius_s <= z_real_sq_s + z_imag_sq_s;

    -- Process could be made multi-cycle for pipelining later on if split here

    z_next_real_o <= std_logic_vector(c_real_s + z_real_sq_s - z_imag_sq_s);
    z_next_imag_o <= std_logic_vector(c_imag_s + z_real_imag_mult_s);



    -- Radius compare
    rcomp : process (z_radius_s) is
    begin
      -- Signal init
      z_greater_r_o <= '0';
      if to_integer(z_radius_s) > R_SQ then
        z_greater_r_o <= '1';
      end if;
    end process;


    -- Precision could be improved by truncating only the last output
    -- This would imply non-standard DSPs or all operations to be 36-bit signed



end dataflow;
