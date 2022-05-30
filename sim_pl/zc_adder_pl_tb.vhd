--------------------------------------------------------------------------------
--
-- File     : zc_adder_tb.vhd
-- Author   : Marc Leemann
-- Date     : 09.05.2022
--
-- Context  : Mandelbrot project
--
--------------------------------------------------------------------------------
-- Description :
--  Testbench for zc_adder
--------------------------------------------------------------------------------
-- Dependencies :
--
--------------------------------------------------------------------------------
-- Modifications :
-- Ver   Date        Person     Comments
-- 1.0   09.05.2022  MLN        Initial version
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- file library
use std.textio.all;

library xil_defaultlib;
use xil_defaultlib.iter_pl_pkg.all;
--use iter_pl_pkg.all;


entity zc_adder_pl_tb is
    generic (
    DSP_WIDTH   : integer := 18;
    N_DECIMALS  : integer := 12;
    R_SQ        : integer := 4;
    MAX_ITER    : integer := 100;
    COORD_WIDTH : integer := 10;
    MEM_WIDTH   : integer := 9
    );
end zc_adder_pl_tb;


architecture tb of zc_adder_pl_tb is

    type stimulus_t is record
        coords : coords_t;
        z      : z_t;
        --c_real     : std_logic_vector(SIZE - 1 downto 0);
        --c_imag     : std_logic_vector(SIZE - 1 downto 0);
        --z_real_in  : std_logic_vector(SIZE - 1 downto 0);
        --z_imag_in  : std_logic_vector(SIZE - 1 downto 0);
    end record;

    type observed_t is record
        --z       : z_t;
        mem     : mem_t;
        coords  : coords_t;
        --z_real_o    : std_logic_vector(SIZE - 1 downto 0);
        --z_imag_o    : std_logic_vector(SIZE - 1 downto 0);
        --z_over_r_o  : std_logic;
    end record;

    signal sti : stimulus_t; -- Stimulus
    signal obs : observed_t; -- Observed signals
    signal ref0 : observed_t; -- Reference output signals
    signal ref1 : observed_t;

    -- Clock period
    constant PERIOD : time := 10 ns;

    signal clk_s : std_logic := '0';
    signal rst_s : std_logic := '0';


    -- Simulation flags
    signal sim_over_s : boolean   := false;
    signal sti_ok_s   : std_logic := '0';
    signal err_s      : std_logic := '0';

    -- Path for reference values
    constant txt_path : string := "/run/media/leemarc/Shared/Switchdrive/Private/Documents/Master/2_S2/LPSC/Mandelbrot/lpsc-mandelbrot/sim_pl/";

    -- File declarations (std.textio)
    -- Use python notebook mandelbrot_pl to generate files
    file sti_file : text; -- zo_r zo_c zoverr
    file ref_file : text; -- c_r c_i zi_r zi_c

    -- DUV signals


    -- DUV declaration
    component zc_adder_pl is
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
            mem_o     : out mem_t
        );
    end component;



begin

    duv : zc_adder_pl
    generic map(
        DSP_WIDTH   => DSP_WIDTH,
        N_DECIMALS  => N_DECIMALS,
        R_SQ        => R_SQ,
        MAX_ITER    => MAX_ITER,
        COORD_WIDTH => COORD_WIDTH,
        MEM_WIDTH   => MEM_WIDTH
    )
    port map(
        clk_i     => clk_s,
        rst_i     => rst_s,
        coords_i  => sti.coords,
        coords_o  => obs.coords,
        mem_o     => obs.mem
    );


    -- CLK generation process
    clk : process is
    begin
        while not(sim_over_s) loop
            clk_s <= '0', '1' after PERIOD/2;
            wait for PERIOD;
        end loop;
        wait;
    end process;

    -- Stimulus input
    sti_process: process is
        variable txt_line   : Line;
        variable coords_sti : coords_t;

    begin
        sti_ok_s <= '0';
      -- expression doesn't work with only file name
        file_open(sti_file, txt_path & "sti.txt", READ_MODE);
        --file_open(sti_file, "sti.txt", READ_MODE);

        sti.coords.c_real <= (others => '0');
        sti.coords.c_imag <= (others => '0');
        sti.coords.x      <= (others => '0');
        sti.coords.y      <= (others => '0');
        sti.coords.index  <= '0';

        ref0.coords.c_real <= (others => '0');
        ref0.coords.c_imag <= (others => '0');
        ref0.coords.x      <= (others => '0');
        ref0.coords.y      <= (others => '0');
        ref0.coords.index  <= '0';

        ref1.coords.c_real <= (others => '0');
        ref1.coords.c_imag <= (others => '0');
        ref1.coords.x      <= (others => '0');
        ref1.coords.y      <= (others => '0');
        ref1.coords.index  <= '0';

        sti.z.z_real      <= (others => '0');
        sti.z.z_imag      <= (others => '0');
        coords_sti.index := '1';

        -- Reset input for 3 periods
        wait until rising_edge(clk_s);
        wait for 2 ns;
        rst_s <= '1';
        wait for 3*PERIOD;
        rst_s <= '0';

        while not endfile(sti_file) loop
            sti_ok_s <= '0';
            wait until rising_edge(clk_s);
            if (obs.mem.we = '1') then

              -- read txt line into variable
              readline(sti_file, txt_line);

              -- read txt column into variable (space-separated)
              read(txt_line, coords_sti.c_real);
              read(txt_line, coords_sti.c_imag);
              read(txt_line, coords_sti.x);
              read(txt_line, coords_sti.y);
              coords_sti.index := not coords_sti.index;

              --z_sti.cnt  <= 0;

              sti.coords <= coords_sti;
              ref0.coords <= coords_sti;
              ref1.coords <= coords_sti;

              -- signal new stimulus in
              sti_ok_s <= '1';
              wait for 2 ns;
              sti_ok_s <= '0';
              --wait until obs.mem.we = '0';
              --wait until obs.mem.we = '1';
              --wait until falling_edge(clk_s);
            end if;

        end loop;

        -- close file
        file_close(sti_file);
        --wait for PERIOD*2;
        --wait for 2 ns;
        --wait until obs.mem.we = '1';
        wait for PERIOD;
        --wait until obs.mem.we = '1';
        -- end of simulation
        sim_over_s <= true;
        -- end of procedure
        wait;

    end process; -- stimulus_proc


    -- Reference signal comparison
    ref_process : process is
        variable txt_line   : Line;
        variable mem_ref : mem_t;
    begin
        file_open(ref_file, txt_path & "ref.txt", READ_MODE);
        wait until sti_ok_s = '1';

        readline(ref_file, txt_line);
        -- read txt column into variable (space-separated)
        read(txt_line, mem_ref.addr);
        read(txt_line, mem_ref.data);
        read(txt_line, mem_ref.we);

        ref0.mem <= mem_ref;

        readline(ref_file, txt_line);
        -- read txt column into variable (space-separated)
        read(txt_line, mem_ref.addr);
        read(txt_line, mem_ref.data);
        read(txt_line, mem_ref.we);

        ref1.mem <= mem_ref;
        while not endfile(ref_file) loop
            -- read txt line into variable

            readline(ref_file, txt_line);
            -- read txt column into variable (space-separated)
            read(txt_line, mem_ref.addr);
            read(txt_line, mem_ref.data);
            read(txt_line, mem_ref.we);

            err_s <= '0';
            -- wait for new stimulus
            wait until sti_ok_s = '1';
            wait for PERIOD;

            -- if matches ref1 -> assign new to ref1
            -- if matches ref0 -> assign new to ref0
            -- Assign to reference signals
            -- fill ref1 with previously unmatched value
            wait until obs.mem.we = '1'; -- wait for write enable output
            wait for 5 ns;
            -- Check observed signal is the same as reference output
            if obs.mem   = ref0.mem then
                ref0.mem <= mem_ref;
                report "OK" severity warning;
                err_s <= '0';
            elsif obs.mem = ref1.mem then
                ref1.mem <= mem_ref;
                report "OK" severity warning;
                err_s <= '0';
            else
                err_s <= '1';
                report "Error" severity error;
                wait for 2 ns;
                err_s <= '0';
            end if;
        end loop;
        wait;
    end process;



end tb;
