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

entity zc_adder_tb is
    generic (
        FIXEDPOINT  : integer := 14;
        SIZE        : integer := 18;
        R_SQ        : integer := 4
    );
end zc_adder_tb;

-- gtkwave et ghdl
architecture tb of zc_adder_tb is

    type stimulus_t is record
        c_real     : std_logic_vector(SIZE - 1 downto 0);
        c_imag     : std_logic_vector(SIZE - 1 downto 0);
        z_real_in  : std_logic_vector(SIZE - 1 downto 0);
        z_imag_in  : std_logic_vector(SIZE - 1 downto 0);
    end record;

    type observed_t is record
        z_real_o    : std_logic_vector(SIZE - 1 downto 0);
        z_imag_o    : std_logic_vector(SIZE - 1 downto 0);
        z_over_r_o  : std_logic;
    end record;

    signal sti : stimulus_t; -- Stimulus
    signal obs : observed_t; -- Observed signals
    signal ref : observed_t; -- Reference output signals

    -- Clock period
    constant PERIOD : time := 10 ns;

    signal clk_s   : std_logic := '0';
    signal reset_s : std_logic := '0';


    -- Simulation flags
    signal sim_over_s : boolean   := false;
    signal sti_ok_s   : std_logic := '0';
    signal err_s      : std_logic := '0';

    -- Path for reference values
    constant txt_path : string := "/run/media/leemarc/Shared/Switchdrive/Private/Documents/Master/2_S2/LPSC/Mandelbrot/lpsc-mandelbrot/sim_zc/";

    -- File declarations (std.textio)
    -- Use python notebook mandelbrot_zc to generate files
    file sti_file : text; -- zo_r zo_c zoverr
    file ref_file : text; -- c_r c_i zi_r zi_c


    -- DUV declaration
    component zc_adder is
        generic (
            SIZE : integer := 18;
            FIXEDPOINT : integer := 4;
            R_SQ : integer := 4
        );
        port (
            z_real_i      : in  std_logic_vector(SIZE-1 downto 0);
            z_imag_i      : in  std_logic_vector(SIZE-1 downto 0);
            c_real_i      : in  std_logic_vector(SIZE-1 downto 0);
            c_imag_i      : in  std_logic_vector(SIZE-1 downto 0);
            z_next_real_o : out std_logic_vector(SIZE-1 downto 0);
            z_next_imag_o : out std_logic_vector(SIZE-1 downto 0);
            z_greater_r_o : out std_logic
        );
    end component;



begin

    duv : zc_adder
    generic map(
        FIXEDPOINT  => FIXEDPOINT,
        SIZE        => SIZE,
        R_SQ        => R_SQ
    )
    port map(
        z_real_i        => sti.z_real_in,
        z_imag_i        => sti.z_imag_in,
        c_real_i        => sti.c_real,
        c_imag_i        => sti.c_imag,
        z_next_real_o   => obs.z_real_o,
        z_next_imag_o   => obs.z_imag_o,
        z_greater_r_o   => obs.z_over_r_o
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
        variable c_real_sti   : std_logic_vector(SIZE - 1 downto 0);
        variable c_imag_sti   : std_logic_vector(SIZE - 1 downto 0);
        variable z_real_sti   : std_logic_vector(SIZE - 1 downto 0);
        variable z_imag_sti   : std_logic_vector(SIZE - 1 downto 0);

    begin
      -- expression doesn't work with only file name
        file_open(sti_file, txt_path & "sti.txt", READ_MODE);
        --file_open(sti_file, "sti.txt", READ_MODE);

        sti.c_real    <= (others => '0');
        sti.c_imag    <= (others => '0');
        sti.z_real_in <= (others => '0');
        sti.z_imag_in <= (others => '0');

        -- Reset input for 3 periods
        wait until rising_edge(clk_s);
        reset_s <= '1';
        wait for 3*PERIOD;

        reset_s <= '0';
        wait for 2*PERIOD;

        while not endfile(sti_file) loop
            -- read txt line into variable
            readline(sti_file, txt_line);

            -- read txt column into variable (space-separated)
            read(txt_line, c_real_sti);
            read(txt_line, c_imag_sti);
            read(txt_line, z_real_sti);
            read(txt_line, z_imag_sti);

            sti.c_real    <= c_real_sti;
            sti.c_imag    <= c_imag_sti;
            sti.z_real_in <= z_real_sti;
            sti.z_imag_in <= z_imag_sti;

            wait until falling_edge(clk_s);
            wait for 2 ns;
            -- signal new stimulus in
            sti_ok_s <= '1';

        end loop;

        -- close file
        file_close(sti_file);

        -- end of simulation
        sim_over_s <= true;

        -- end of procedure
        wait;

    end process; -- stimulus_proc


    -- Reference signal comparison
    ref_process : process is
        variable txt_line   : Line;
        variable z_real_ref   : std_logic_vector(SIZE - 1 downto 0);
        variable z_imag_ref   : std_logic_vector(SIZE - 1 downto 0);
        variable z_over_r_ref     : std_logic;
    begin
        file_open(ref_file, txt_path & "ref.txt", READ_MODE);
        --file_open(ref_file, "ref.txt", READ_MODE);

        -- wait for new stimulus
        wait until sti_ok_s = '1';

        while not endfile(ref_file) loop
            -- read txt line into variable
            readline(ref_file, txt_line);

            -- read txt column into variable (space-separated)
            read(txt_line, z_real_ref);
            read(txt_line, z_imag_ref);
            read(txt_line, z_over_r_ref);

            -- Assign to reference signals
            ref.z_real_o    <= z_real_ref;
            ref.z_imag_o    <= z_imag_ref;
            ref.z_over_r_o  <= z_over_r_ref;

            -- Check observed signal is the same as reference output
            if obs.z_real_o     = ref.z_real_o      and
               obs.z_imag_o     = ref.z_imag_o      and
               obs.z_over_r_o = ref.z_over_r_o  then
                err_s <= '1';
                report "Error" severity error;
            else
                report "OK" severity warning;
            end if;


            wait until rising_edge(clk_s);
            wait for 2 ns;

        end loop;
        wait;
    end process;



end tb;
