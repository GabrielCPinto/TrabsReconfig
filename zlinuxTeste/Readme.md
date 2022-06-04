sudo apt-get install ghdl gtkwave

comandos ghdl

-s Syntax verfy



teste

ghdl -a control_unit.vhd
ghdl -a test.vhd

ghdl -e test
ghdl -r test
ghdl -r test --vcd=test.vcd
gtkwave test.vcd