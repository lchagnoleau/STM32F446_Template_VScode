CC_FLAGS = -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16
CC_FLAGS_OBJS = $(CC_FLAGS) -DSTM32 -DUSE_STDPERIPH_DRIVER -DSTM32F446xx -DSTM32F4 -DSTM32F446RETx -DDEBUG
CC_FLAGS_ELF = $(CC_FLAGS) -T"LinkerScript.ld" -Wl,-Map=output.map -Wl,--gc-sections

CC_INCLUDE = app/inc drivers/st/inc CMSIS/inc CMSIS/device/inc
CC_SOURCE = app/src drivers/st/src startup
CC_PARAMS=$(foreach d, $(CC_INCLUDE), -I$d) 
RM = rm -rf
MK = mkdir -p
PWD = $(shell pwd)

BINDIR = bin
OBJDIR = obj
OUTPUT = STM32F446_VS_CODE_TEMPLATE
RELEASEDIR = release

SOURCES := $(notdir $(shell find $(CC_SOURCE) -name '*.c'))
OBJECTS := $(addprefix $(OBJDIR)/,$(SOURCES:%.c=%.o))
OBJECTS += $(OBJDIR)/startup/startup_stm32f446xx.o


VPATH += $(CC_SOURCE)

all: dir $(OUTPUT).elf

$(OUTPUT).elf: $(OBJECTS) LinkerScript.ld
	@echo 'Building target: $@'
	@echo 'Invoking: MCU GCC Linker'
	arm-none-eabi-gcc $(CC_FLAGS_ELF) -o $(BINDIR)/$(OUTPUT).elf $(OBJECTS) -lm
	@echo 'Finished building target: $@'
	@echo ' '
	$(MAKE) --no-print-directory post-build

$(OBJDIR)/startup/%.o: startup/%.s
	@echo 'Building file: $<'
	@echo 'Invoking: MCU GCC Assembler'
	@echo $(PWD)
	arm-none-eabi-as $(CC_FLAGS) -g -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

$(OBJDIR)/%.o: %.c
	@echo 'Building file: $@'
	@echo 'Invoking: C Compiler'
	arm-none-eabi-gcc $(CC_PARAMS) $(CC_FLAGS_OBJS) -c -o $@ $<
	@echo 'Finished building: $@'
	@echo ' '

post-build:
	-@echo 'Generating binary and Printing size information:'
	arm-none-eabi-objcopy -O binary "$(BINDIR)/$(OUTPUT).elf" "$(BINDIR)/$(OUTPUT).bin"
	arm-none-eabi-size "$(BINDIR)/$(OUTPUT).elf"
	-@echo ' '

dir:
	@echo 'Creat output folders'
	$(MK) $(BINDIR) $(OBJDIR) $(OBJDIR)/startup
	@echo ' '

clean:
	@echo 'Clean output folders'
	$(RM) $(BINDIR)/ $(OBJDIR)/ $(RELEASEDIR)/
	@echo ' '