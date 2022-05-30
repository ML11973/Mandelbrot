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
--------------------------------------------------------------------------------
-- Dependencies :
--
--------------------------------------------------------------------------------
-- Modifications :
-- Ver   Date        Person     Comments
-- 1.0   24.05.2022  MLN        Initial version
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library xil_defaultlib;
use xil_defaultlib.iter_pl_pkg.all;
--use iter_pl_pkg.all;

entity zc_adder_pl is
    generic (
        DSP_WIDTH   : integer := DSP_WIDTH;
        N_DECIMALS  : integer := N_DECIMALS;
        R_SQ        : integer := R_SQ;
        MAX_ITER    : integer := MAX_ITER;
        COORD_WIDTH : integer := COORD_WIDTH;
        MEM_WIDTH   : integer := MEM_WIDTH
    );
    port (
        clk_i : in  std_logic;
        rst_i : in  std_logic;

        coords_i  : in  coords_t;
        coords_o  : out coords_t;
        --z_i       : in  z_t;
        --z_o       : out z_t;
        mem_o     : out mem_t
    );
end zc_adder_pl;
architecture seq of zc_adder_pl is
    -- Pipeline input stage (combinatory)
    signal coords_s0 : coords_t;
    signal z_s0      : z_t;
    -- Pipeline stage 1 (register)
    signal coords_s1 : coords_t;
    signal z_s1      : z_t;
    -- Pipeline output stage (register)
    signal coords_s2 : coords_t;
    signal z_s2      : z_t;

    -- Intermediate numbers
    signal z_real_sq_big_s          : signed(2*DSP_WIDTH-1 downto 0);
    signal z_imag_sq_big_s          : signed(2*DSP_WIDTH-1 downto 0);
    signal z_real_imag_mult_big_s   : signed(2*DSP_WIDTH-1 downto 0);

    signal z_real_sq_s              : signed(DSP_WIDTH-1 downto 0);
    signal z_imag_sq_s              : signed(DSP_WIDTH-1 downto 0);
    signal z_real_imag_mult_s       : signed(DSP_WIDTH-1 downto 0);

    signal z_next_real_s            : signed(DSP_WIDTH-1 downto 0);
    signal z_next_imag_s            : signed(DSP_WIDTH-1 downto 0);
    signal z_next_real_sq_s         : signed(DSP_WIDTH-1 downto 0);
    signal z_next_imag_sq_s         : signed(DSP_WIDTH-1 downto 0);
    signal z_next_real_sq_big_s     : signed(2*DSP_WIDTH-1 downto 0);
    signal z_next_imag_sq_big_s     : signed(2*DSP_WIDTH-1 downto 0);

    signal z_rsq_s                  : signed(DSP_WIDTH-1 downto 0);

    signal div_s          : std_logic;
    signal conv_s         : std_logic;
    signal nextval_init_s : std_logic;
    signal nextval_init0_s: std_logic;
    signal we_delay_s     : std_logic;
    signal empty_pl_s     : std_logic; -- signal to mask input for first load
    signal empty_pl0_s : std_logic;




begin

    -- PIPELINE INPUT STAGE (combinatory logic)
    inputstage : process(all) is
    begin
      if rst_i then
        coords_s0.c_real  <= (others=>'0');
        coords_s0.c_imag  <= (others=>'0');
        coords_s0.x       <= (others=>'0');
        coords_s0.y       <= (others=>'0');
        coords_s0.index   <= '0';
        z_s0.z_real       <= (others=>'0');
        z_s0.z_imag       <= (others=>'0');
        z_s0.cnt <= 0;
      elsif we_delay_s then--mem_o.we then--or we_delay_s then -- Reset z and input c
        coords_s0   <= coords_i;
        z_s0.z_real <= (others=>'0');
        z_s0.z_imag <= (others=>'0');
        z_s0.cnt <= 0;
      else
        coords_s0 <= coords_s2;
        z_s0      <= z_s2;
        z_s0.cnt  <= z_s2.cnt;
      end if;
    end process;


    -- Original formulas:
    -- R(Znext) = R(z)^2 - I(z)^2 + R(c)
    -- I(Znext) = 2*R(z)*I(z) + I(c)

    z_real_sq_big_s         <= (z_s0.z_real * z_s0.z_real);
    z_imag_sq_big_s         <= (z_s0.z_imag * z_s0.z_imag);
    z_real_imag_mult_big_s  <= (z_s0.z_real * z_s0.z_imag);


    -- Example: Size = 18, FIXEDPOINT = 14, D -> decimal, I -> integer, S -> sign
    -- z_real_sq_big(35 downto 0)   -> z_real_sq((18+4-1) downto 4)
    -- z_real_sq_big: SI-7x--I.D------------28x-----------D
    -- z_real_sq:     SXXXXIII.D----14x-----DXXXXXXXXXXXXXX
    --                35   30               14            0
    z_real_sq_s <=  z_real_sq_big_s(2*DSP_WIDTH-1) & -- sign bit
                    z_real_sq_big_s((N_DECIMALS+DSP_WIDTH-2) downto N_DECIMALS);
    z_imag_sq_s <=  z_imag_sq_big_s(2*DSP_WIDTH-1) & -- sign bit
                    z_imag_sq_big_s((N_DECIMALS+DSP_WIDTH-2) downto N_DECIMALS);

    z_real_imag_mult_s <= z_real_imag_mult_big_s(2*DSP_WIDTH-1) & --sign bit
                z_real_imag_mult_big_s((N_DECIMALS+DSP_WIDTH-3) downto N_DECIMALS-1); -- cross-product is multiplied by 2 by bit-shift

    z_next_real_s <= coords_s0.c_real + z_real_sq_s - z_imag_sq_s;
    z_next_imag_s <= coords_s0.c_imag + z_real_imag_mult_s;

    --PIPELINE-----------------------------------------------------------------
    -- Pipeline is placed here -> adder and multiplier on each side
    stage1 : process(clk_i) is
    begin
      if rising_edge(clk_i) then
        if rst_i then
          coords_s1.c_real  <= (others=>'0');
          coords_s1.c_imag  <= (others=>'0');
          coords_s1.x       <= (others=>'0');
          coords_s1.y       <= (others=>'0');
          coords_s1.index   <= '0';
          z_s1.z_real       <= (others=>'0');
          z_s1.z_imag       <= (others=>'0');
          z_s1.cnt          <= 0;
        else -- Update registers
          coords_s1       <= coords_s0;
          z_s1.z_real     <= z_next_real_s;
          z_s1.z_imag     <= z_next_imag_s;
          z_s1.cnt        <= z_s0.cnt+1;
        end if;
      end if;
    end process;

    -- Computing znext radius
    z_next_real_sq_big_s  <= (z_s1.z_real * z_s1.z_real);
    z_next_imag_sq_big_s  <= (z_s1.z_imag * z_s1.z_imag);

    z_next_real_sq_s <=                         z_next_real_sq_big_s((N_DECIMALS+DSP_WIDTH-1) downto N_DECIMALS);

    z_next_imag_sq_s <=                         z_next_imag_sq_big_s((N_DECIMALS+DSP_WIDTH-1) downto N_DECIMALS);
    z_rsq_s <= z_next_real_sq_s + z_next_imag_sq_s;

    -- Mem outputs
    mem_o.addr <= coords_s1.y & coords_s1.x;
    -- For testbench operation
    --mem_o.data <= std_logic_vector(to_unsigned(z_s1.cnt,mem_o.data'length));
    mem_o.data <= (others=>'1') when conv_s else (others=>'0');
    mem_o.we   <= div_s or conv_s or nextval_init_s;

    coords_o <= coords_s2;

    -- PIPELINE OUTPUT STAGE (registers)
    outputstage : process(clk_i) is
    begin
      if rising_edge(clk_i) then
        if rst_i then
          coords_s2.c_real  <= (others=>'0');
          coords_s2.c_imag  <= (others=>'0');
          coords_s2.x       <= (others=>'0');
          coords_s2.y       <= (others=>'0');
          coords_s2.index   <= '0';
          z_s2.z_real       <= (others=>'0');
          z_s2.z_imag       <= (others=>'0');
          z_s2.cnt          <= 0;
        --elsif mem_o.we then
        --  coords_s2.c_real  <= (others=>'0');
        --  coords_s2.c_imag  <= (others=>'0');
        --  coords_s2.x       <= (others=>'0');
        --  coords_s2.y       <= (others=>'0');
        --  coords_s2.index   <= '0';
        --  z_s2.z_real       <= (others=>'0');
        --  z_s2.z_imag       <= (others=>'0');
        --  z_s2.cnt          <= 0;
        else
          coords_s2 <= coords_s1;
          z_s2      <= z_s1;
        end if;
      end if;
    end process;

    -- nextval init (initial two-value loading)
    nextval_gen : process(clk_i) is
    begin
      if rising_edge(clk_i) then
        if rst_i then
          nextval_init0_s <= '1';
          nextval_init_s  <= '1';
          empty_pl0_s     <= '1';
          empty_pl_s      <= '1';
          we_delay_s      <= '1';
        else
          nextval_init0_s <= '0';
          nextval_init_s  <= nextval_init0_s;
          empty_pl0_s     <= nextval_init_s;
          empty_pl_s      <= empty_pl0_s;
          we_delay_s      <= mem_o.we;
        end if;
      end if;
    end process;


    -- Radius compare
    divconv : process (all) is
    begin
      -- Signal init
      div_s  <= '0';
      conv_s <= '0';
      -- only compare integer part of z_rsq_s
      if to_integer(z_rsq_s(DSP_WIDTH-1 downto N_DECIMALS)) >= R_SQ then
        div_s <= '1';
      end if;

      -- converges if MAX_ITER is reached
      if z_s1.cnt >= MAX_ITER then
        conv_s <= '1';
      end if;
    end process;


end seq;
