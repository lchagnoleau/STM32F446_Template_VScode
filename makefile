CC = arm-none-eabi-gcc
CC_FLAGS_OBJS = -mcpu=cortex-m4 -mthumb -mfloat-abi=soft -DSTM32F446xx -DDEBUG -DUSE_STDPERIPH_DRIVER
CC_FLAGS_ELF = -mcpu=cortex-m4 -mthumb -mfloat-abi=soft -specs=rdimon.specs -lc -lrdimon -T"LinkerScript.ld" -Wl,-Map=output.map -Wl,--gc-sections

CC_INCLUDE = app/inc drivers/st/inc CMSIS/inc CMSIS/device/inc
CC_SOURCE = app/src drivers/st/src startup
CC_PARAMS=$(foreach d, $(CC_INCLUDE), -I$d) 
RM = rm -rf
MK = mkdir -p

BINDIR = bin
OBJDIR = obj
OUTPUT = STM32F446_VS_CODE_TEMPLATE.elf
RELEASEDIR = release

SOURCES := $(notdir $(shell find $(CC_SOURCE) -name '*.c'))
OBJECTS := $(addprefix $(OBJDIR)/,$(SOURCES:%.c=%.o))

SOURCES += $(notdir $(shell find $(CC_SOURCE) -name '*.s'))
OBJECTS += $(addprefix $(OBJDIR)/,$(SOURCES:%.s=%.o))

VPATH += $(CC_SOURCE)

all: dir $(OUTPUT)

$(OUTPUT): $(OBJECTS) LinkerScript.ld
	@echo 'Building target: $@'
	@echo 'Invoking: MCU GCC Linker'
	$(CC) $(CC_PARAMS) $(CC_FLAGS_ELF) -o $(BINDIR)/$(OUTPUT) $(OBJECTS) -lm
	@echo 'Finished building target: $@'
	@echo ' '
	$(MAKE) --no-print-directory post-build

$(OBJDIR)/%.o: %.c
	@echo 'Building file: $@'
	@echo 'Invoking: C Compiler'
	$(CC) $(CC_PARAMS) $(CC_FLAGS_OBJS) -c -o $@ $<
	@echo 'Finished building: $@'
	@echo ' '

dir:
	@echo 'Creat output folders'
	$(MK) $(BINDIR) $(OBJDIR)
	@echo ' '

clean:
	@echo 'Clean output folders'
	$(RM) $(BINDIR)/ $(OBJDIR)/ $(RELEASEDIR)/
	rm -f distrib/ptu_fs/usr/local/bin/ptu_controller
	distrib/ptu_fs.sh -a clean 
	@echo ' '