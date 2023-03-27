TARGET = project
BUILD_DIR = build

SRC = ./main.c ./system_stm32f4xx.c
ASM = ./startup_stm32f401xc.s
LDS = ./stm32f401xc_flash.ld
MCU = -mcpu=cortex-m4 -mthumb
DEF = -DSTM32F401xC
OPT = -O3 -g0 -flto
INC = -I./include

ifdef GCC_PATH
  TOOLCHAIN = $(GCC_PATH)/arm-none-eabi-
else
  TOOLCHAIN = arm-none-eabi-
endif

CC = $(TOOLCHAIN)gcc
AS = $(TOOLCHAIN)gcc -x assembler-with-cpp
CP = $(TOOLCHAIN)objcopy
SZ = $(TOOLCHAIN)size

HEX = $(CP) -O ihex
BIN = $(CP) -O binary -S

FLAG = $(MCU) $(DEF) $(INC) -Wall -Werror -Wextra -Wpedantic -fdata-sections -ffunction-sections

FLAG += -MMD -MP -MF $(@:%.o=%.d)

LIB = -lc -lm -lnosys
LDFLAGS = $(MCU) -specs=nano.specs -T$(LDS) $(LIB) -Wl,-Map=$(BUILD_DIR)/$(TARGET).map,--cref -Wl,--gc-sections

all:: $(BUILD_DIR)/$(TARGET).elf $(BUILD_DIR)/$(TARGET).hex $(BUILD_DIR)/$(TARGET).bin

OBJ = $(addprefix $(BUILD_DIR)/,$(notdir $(SRC:.c=.o)))
vpath %.c $(sort $(dir $(SRC)))

OBJ += $(addprefix $(BUILD_DIR)/,$(notdir $(ASM:.s=.o)))
vpath %.s $(sort $(dir $(ASM)))

$(BUILD_DIR)/%.o: %.c Makefile | $(BUILD_DIR)
	$(CC) -c $(FLAG) $(OPT) $(EXT) $< -o $@

$(BUILD_DIR)/%.o: %.s Makefile | $(BUILD_DIR)
	$(AS) -c $(FLAG) $(OPT) $(EXT) -Wa,-a,-ad,-alms=$(BUILD_DIR)/$(notdir $(<:.c=.lst)) $< -o $@

$(BUILD_DIR)/$(TARGET).elf: $(OBJ) Makefile
	$(CC) $(OBJ) $(LDFLAGS) $(OPT) $(EXT) -o $@
	$(SZ) $@

$(BUILD_DIR)/%.hex: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	$(HEX) $< $@

$(BUILD_DIR)/%.bin: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	$(BIN) $< $@

$(BUILD_DIR):
	mkdir $@

debug:: OPT = -Og -g3 -gdwarf
debug:: FLAG += -DDEBUG
debug:: all

clean::
	rm -fR $(BUILD_DIR)

-include $(wildcard $(BUILD_DIR)/*.d)

