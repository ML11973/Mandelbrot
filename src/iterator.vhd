--------------------------------------------------------------------------------
--
-- File     : iterator.vhd
-- Author   : Marc Leemann
-- Date     : 09.05.2022
--
-- Context  : Mandelbrot project
--
--------------------------------------------------------------------------------
-- Description :
--  Iterator to compute Mandelbrot series until convergence or max iterations.
--  Feeds Z and C-values back to ZC adder until result is greater than radius
--  generic (R_SQ) or max iterations (generic) were reached.
--------------------------------------------------------------------------------
-- Dependencies :
--  zc_adder.vhd
--------------------------------------------------------------------------------
-- Modifications :
-- Ver   Date        Person     Comments
-- 1.0   09.05.2022  MLN        Initial version
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;


entity iterator is
    generic (
        R_SQ          : integer := 4;
        DSP_WIDTH     : integer := 18;
        N_DECIMALS    : integer := 4;
        MAX_ITER      : integer := 100
    );
    port (
        clk_i     : in std_logic;
        rst_i     : in std_logic;
        z_real_i  : in std_logic_vector(DSP_WIDTH-1 downto 0);
        z_imag_i  : in std_logic_vector(DSP_WIDTH-1 downto 0);
        c_real_i  : in std_logic_vector(DSP_WIDTH-1 downto 0);
        c_imag_i  : in std_logic_vector(DSP_WIDTH-1 downto 0)

        -- Control signals
        ready_o : out std_logic;
        load_i  : in  std_logic

        --control_i : in morse_burst_emitter_control_in_t;
        --control_o : out morse_burst_emitter_control_out_t;
        --morse_o   : out std_logic
    );
end iterator;
architecture seq of iterator is

    -- Component declarations
    component zc_adder
      generic (
          SIZE : integer := 18;
          FIXEDPOINT : integer := 4;
          R_SQ : integer := 4
      );
      port (
          --clk_i     : in std_logic;
          --rst_i     : in std_logic;
          z_real_i      : in  std_logic_vector(SIZE-1 downto 0);
          z_imag_i      : in  std_logic_vector(SIZE-1 downto 0);
          c_real_i      : in  std_logic_vector(SIZE-1 downto 0);
          c_imag_i      : in  std_logic_vector(SIZE-1 downto 0);
          z_next_real_o : out std_logic_vector(SIZE-1 downto 0);
          z_next_imag_o : out std_logic_vector(SIZE-1 downto 0)
      );
    end component;

    -- Z output from zc_adder
    signal z_real_s       : std_logic_vector(DSP_WIDTH-1 downto 0);
    signal z_imag_s       : std_logic_vector(DSP_WIDTH-1 downto 0);
    signal z_greater_r_s  : std_logic;

    -- zc_adder inputs (registers)
    signal z_next_real_s  : std_logic_vector(DSP_WIDTH-1 downto 0);
    signal z_next_imag_s  : std_logic_vector(DSP_WIDTH-1 downto 0);
    signal c_next_real_s  : std_logic_vector(DSP_WIDTH-1 downto 0);
    signal c_next_imag_s  : std_logic_vector(DSP_WIDTH-1 downto 0);

    -- Iteration counter (register)
    signal iter_cnt_s   : integer range 0 to MAX_ITER; -- TODO check synthesis

    -- Control signals
    signal cnt_incr_s   : std_logic;
    signal load_regs_s  : std_logic;


begin
    load_regs_s <= load_i;
    incr_s <= not z_greater_r_s; -- increment as long as Z^2 > R^2



    adder : zc_adder
    generic map(
        SIZE => DSP_WIDTH,
        FIXEDPOINT => N_DECIMALS,
        R_SQ => R_SQ
    )
    port map(
        z_real_i      => z_next_real_s,
        z_imag_i      => z_next_imag_s,
        c_real_i      => c_next_real_s,
        c_imag_i      => c_next_imag_s,
        z_next_real_o => z_real_s,
        z_next_imag_o => z_imag_s,
        z_greater_r_o => z_greater_r_s
    );



    -- Registers: ZC adder input and counter
    regs : process (clk_i, rst_i) is
    begin
      -- Async reset
      if rst_i then
        z_next_real_s <= (others='0');
        z_next_imag_s <= (others='0');
        c_next_real_s <= (others='0');
        c_next_imag_s <= (others='0');
        iter_cnt_s    <= 0;
      elsif(rising_edge(clk_i)) then
        if load_regs_s then -- Load from inputs -> start sequence
          z_next_real_s <= z_real_i;
          z_next_imag_s <= z_imag_i;
          c_next_real_s <= c_real_i;
          c_next_imag_s <= c_imag_i;
          iter_cnt_s    <= 0; -- reset counter on register load
        elsif cnt_incr_s then
          iter_cnt_s    <= iter_cnt_s + 1; -- TODO check syntax and synthesis
          z_next_real_s <= z_real_s;  -- outputs from ZC adder
          z_next_imag_s <= z_imag_s;
          -- keep C-values
        else -- hold
          -- keep values, do nothing
        end if;
      end if;

    end process;


end seq
