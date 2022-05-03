# Vivado Project Creator

## Version

0.5.4

## Description

A description of the Vivado Project Creator (VPC) tool and a procedure to set it up as a git submodule can be found on the associated Wiki:

https://gitedu.hesge.ch/laurent.gantel/vivado_prj_creator/-/wikis/home

## JSON parameters

JSON tokens used to configure the project to be generated are described in the User Guide:

https://gitedu.hesge.ch/laurent.gantel/vivado_prj_creator/-/wikis/user_guide/JSON-Configuration-Tokens

<!--
  Documentation to create a design project for an IP, a package or a peripheral.
-->
## Create a Design Project

If you create an **IP Project** Design called *test_uart*, information about the directory tree of the created project is printed as follow:

```bash
> Project type: DESIGN_PRJ_TYPE
> Project category: IPS
> Project directory: ../../ips/vivado/test_uart/2017.4
> Component directory: ../../ips/hw

> test_uart project directory tree successfully created
> Project scripts successfully generated
> Design scripts successfully generated
> HDL sources successfully generated
> Utility scripts successfully copied
```

The directory tree generated for this project is detailed below:

```
ips
├── hw
└── vivado
    └── test_uart
        └── 2017.4
            ├── lin64
            │   ├── setup.sh
            │   └─── .scripts
            │       ├── clean_prj_test_uart.sh
            │       ├── create_prj_test_uart.sh
            │       ├── create_prj_test_uart.tcl
            │       ├── export_hw_test_uart.sh
            │       ├── export_hw_test_uart.tcl
            │       ├── gen_bitstream_test_uart.sh
            │       ├── gen_bitstream_test_uart.tcl
            │       ├── gen_sw_apps_test_uart.sh
            │       ├── gen_sw_apps_test_uart.tcl
            │       ├── load_bitstream_test_uart.sh
            │       ├── load_bitstream_test_uart.tcl
            │       ├── load_sw_app_test_uart.sh
            │       ├── load_sw_app_test_uart.tcl
            │       ├── open_prj_test_uart.sh
            │       ├── utils.tcl
            │       └── .prompt_colors.tcl
            └── src
                ├── constrs
                │   └── test_uart.xdc
                ├── custom_ip
                ├── hdl
                │   └── test_uart.vhd
                ├── ipi_tcl
                │   └── test_uart_ipi.tcl
                └── sim
                    └── tb_test_uart.vhd
```


The *lin64/.scripts* directory contains the scripts to manage the Vivado project:

* Project creation and deletion:
   * **clean_prj_test_uart.sh** : Cleanup the project directory (remove the generated project and the temporary files)
   * **create_prj_test_uart.sh** : Create a new Vivado project
   * **create_prj_test_uart.tcl** : Vivado TCL script called by *create_prj_test_uart.sh*
   * **open_prj_test_uart.sh** : If created, open the Vivado project *(open the GUI IDE)*

* Hardware design export:
   * **export_hw_test_uart.sh** : Export the hardware design to Vivado SDK - should be called only after bitstream generation
   * **export_hw_test_uart.tcl** : Vivado TCL script called by *export_hw_test_uart.sh*

* Bitstream and software application generation:
   * **gen_bitstream_test_uart.sh** : Generate the bitstream - goes through Synthesis and Place-and-Route
   * **gen_bitstream_test_uart.tcl** : Vivado TCL script called by *gen_bitstream_test_uart.sh*
   * **gen_sw_apps_test_uart.sh** : Generate a BSP and an empty software project - should be called only after hardware export
   * **gen_sw_apps_test_uart.tcl** : Vivado TCL script called by *gen_sw_apps_test_uart.sh*

* Bitstream and software application loading:
   * **load_bitstream_test_uart.sh** : Load a bitstream file into the FPGA - should be called only after bitstream generation
   * **load_bitstream_test_uart.tcl** : Vivado TCL script called by *load_bitstream_test_uart.sh*
   * **load_sw_app_test_uart.sh** - Load the software application in the FPGA (ie. in the ARM for a Zynq) - should be called only after bitstream loading and software projects generation
   * **load_sw_app_test_uart.tcl** : Vivado TCL script called by *load_sw_app_test_uart.sh*

The script **setup.sh** allows to create aliases to ease the use of the above scripts:
```bash
$ source setup.sh
```

The defined aliases are the following:
   * clean\_prj\_&lt;project_name&gt; &rarr; **clean_project**
   * create\_prj\_&lt;project_name&gt; &rarr; **create_project**
   * open\_prj\_&lt;project_name&gt; &rarr; **open_gui**
   * export\_hw\_&lt;project_name&gt; &rarr; **export_hw**
   * gen\_bitstream_&lt;project_name&gt; &rarr; **gen_bitstream**
   * load\_bitstream\_&lt;project_name&gt; &rarr; **load_bitstream**
   * gen\_sw\_apps_&lt;project_name&gt; &rarr; **gen_sw_apps**
   * load\_sw\_app\_&lt;project_name&gt; &rarr; **load_sw_app**


The *src* directory contains the project source files:
   * **constr/test_uart.xdc** : Empty constraints file
   * **custom_ip** : Directory used to store custom IP IP-XACT files used by the project if any
   * **hdl/test_uart.vhd** : Top-level HDL files
   * **ipi_tcl** : Directory used to store IPI files *(block design)* used by the project if any
   * **sim/tb_test_uart** : Top-level HDL simulation file


## Create an IP Component Project

The directory tree generated for a component is detailed below. The **hw** directory contains the sources of the component and the **vivado** directory contains the Vivado project that allows to create and export the component to the hw directory.

```
ips
├── hw
│   └── uart
│       └── src
│           ├── hdl
│           │   └── uart.vhd
│           └── sim
│               └── tb_uart.vhd
└── vivado
  └── uart
        └── 2017.4
            ├── lin64
            │   ├── setup.sh
            │   └─── .scripts
            │       ├── clean_prj_uart.sh
            │       ├── create_prj_uart.sh
            │       ├── create_prj_uart.tcl
            │       └── open_prj_test_uart.sh
            └── src
                └── ipi_tcl
                    └── uart_ipi.tcl
```

For the purpose of each generated file, see **Create a Design Project** subsection.

The same applies when creating a package.

<!--
  Documentation to create a Peripheral Component project. In addition to the component files, generate also the software drivers for Vivado SDK.
-->
## Create a Peripheral Component projects

The directory tree generated for a peripheral is detailed below. In addition to the project scripts and HDL sources, **peripheral drivers** are also generated in the drivers subdirectory.

```
peripherals
├── hw
│   ├── axi4_leds
│   │   ├── drivers
│   │   │   └── axi4_leds_v1_0
│   │   │       ├── data
│   │   │       │   └── axi4_leds.mdd
│   │   │       └── src
│   │   │           ├── axi4_leds.c
│   │   │           ├── axi4_leds.h
│   │   │           └── Makefile
│   │   └── src
│   │       ├── hdl
│   │       │   ├── axi4_leds_S00_axi.vhd
│   │       │   └── axi4_leds.vhd
│   │       └── sim
│   │           └── tb_axi4_leds.vhd
└── vivado
    └── axi4_leds
        └── 2017.4
            ├── lin64
            │   ├── setup.sh
            │   └─── .scripts
            │       ├── clean_prj_axi4_leds.sh
            │       ├── create_prj_axi4_leds.sh
            │       ├── create_prj_axi4_leds.tcl
            │       └── open_prj_test_uart.tcl
            └── src
                └── ipi_tcl
                    └── axi4_leds_ipi.tcl
```

The generated drivers files are the following:
* hw/axi4_leds/drivers/axi4_leds_v1_0/data/axi4_leds.mdd : Microprocessor Driver Definition - Define the driver name, the supported periphals, the version and other options
* hw/axi4_leds/drivers/axi4_leds_v1_0/src/axi4_leds.c : C source file
* hw/axi4_leds/drivers/axi4_leds_v1_0/src/axi4_leds.h : C header file
* hw/axi4_leds/drivers/axi4_leds_v1_0/src/Makefile : Makefile used to compile the driver

In addition to the basic HDL files, the following files are also generated:
* hw/axi4_leds/src/hdl/axi4_leds_S00_axi.vhd : An interface defining the peripheral registers and the logic associated to read and write in these registers
* hw/axi4_leds/src/sim/tb_axi4_leds.vhd : A functional testbench to test the periphal registers

For the purpose of other generated file, see **Create a Design Project** subsection.
