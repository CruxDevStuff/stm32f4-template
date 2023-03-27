# launch openocd and gdb
# $1 - path to .elf 
openocd -f /usr/share/openocd/scripts/interface/stlink.cfg -f/usr/share/openocd/scripts/target/stm32f4x.cfg & 
gdb-multiarch $1 -ex "target remote localhost:3333"  

wait


