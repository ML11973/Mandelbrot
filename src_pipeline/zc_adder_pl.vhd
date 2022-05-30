--------------------------------------------------------------------------------
--
-- File     : zc_adder_pl.vhd
-- Author   : Marc Leemann
-- Date     : 23.05.2022
--
-- Context  : Mandelbrot project
--
--------------------------------------------------------------------------------
-- Description :
--  Combinatory implementation of
--  R(Znext) = R(z)^2 - I(z)^2 + R(c)
--  I(Znext) = 2*R(z)*I(z) + I(c)
--  With a register in the middle to create a 2-stage pipeline
--  Based on original full-combinatory zc_adder
--
--  To use for Mandelbrot series computing with an iterator
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

--library iter_pl;
--use iter_pl.iter_pl_pkg.all;
library xil_defaultlib;
use xil_defaultlib.iter_pl_pkg.all;


entity zc_adder_pl is
    generic (
        SIZE : integer := 18;
        FIXEDPOINT : integer := 14;
        R_SQ : integer := 4
    );
    port (
        clk_i : in std_logic;
        rst_i : in std_logic;
        zc_i  : in iter_zc_out_t;
        zc_o  : out iter_zc_in_t
    );
end zc_adder_pl;
architecture seq of zc_adder_pl is

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

    -- Registers for pipeline stage
    signal z_next_inter_real_s      : signed(SIZE-1 downto 0);
    signal z_next_inter_imag_s      : signed(SIZE-1 downto 0);
    signal addr_pl_inter_s          : std_logic;


begin

  -- Pipeline locations indicated as PIPELINE
  -- TODO synth and check proper DSP usage -> RTL view

    z_real_s <= signed(zc_i.z_real);
    z_imag_s <= signed(zc_i.z_imag);
    c_real_s <= signed(zc_i.c_real);
    c_imag_s <= signed(zc_i.c_imag);

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
    -- Pipeline is placed here -> adder and multiplier on each side
    pipe_reg : process(clk_i) is
    begin
      if rising_edge(clk_i) then
        if rst_i then
          z_next_inter_real_s <= (others=>'0');
          z_next_inter_imag_s <= (others=>'0');
          addr_pl_inter_s     <= '0';
        else -- Update registers
          z_next_inter_real_s <= z_next_real_s;
          z_next_inter_imag_s <= z_next_imag_s;
          addr_pl_inter_s     <= zc_i.addr_pl;
        end if;
      end if;
    end process;

    -- Computing znext radius
    z_next_real_sq_big_s  <= (z_next_inter_real_s * z_next_inter_real_s);
    z_next_imag_sq_big_s  <= (z_next_inter_imag_s * z_next_inter_imag_s);

    z_next_real_sq_s <= z_next_real_sq_big_s(2*SIZE-1) & -- sign bit
                        z_next_real_sq_big_s((FIXEDPOINT+SIZE-2) downto FIXEDPOINT);

    z_next_imag_sq_s <= z_next_imag_sq_big_s(2*SIZE-1) & -- sign bit
                        z_next_imag_sq_big_s((FIXEDPOINT+SIZE-2) downto FIXEDPOINT);

    -- OUTPUTS

    zc_o.z_next_real  <= std_logic_vector(z_next_inter_real_s);
    zc_o.z_next_imag  <= std_logic_vector(z_next_inter_imag_s);
    zc_o.addr_pl      <= addr_pl_inter_s;

    --PIPELINE-----------------------------------------------------------------
    z_rsq_s <= z_next_real_sq_s + z_next_imag_sq_s;

    --PIPELINE-----------------------------------------------------------------
    -- Radius compare
    rcomp : process (all) is
    begin
      -- Signal init
      zc_o.z_greater_r <= '0';
      -- only compare integer part of z_rsq_s
      -- converges if MAX_ITER is reached
      if to_integer(z_rsq_s(SIZE-1 downto FIXEDPOINT)) >= R_SQ then
        zc_o.z_greater_r <= '1';
      end if;
    end process;


    -- Precision could be improved by truncating only the last output
    -- This would imply non-standard DSPs or all operations to be 36-bit signed



end seq;
