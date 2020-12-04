BINDIR = bin
OBJDIR = obj
OUTPUT = STM32F446_VS_CODE_TEMPLATE
RELEASEDIR = release
CC = arm-none-eabi-gcc
RM = rm -rf
MK = mkdir -p
PWD = $(shell pwd)

CC_INCLUDE = 	app/inc \
				drivers/st/inc \
				CMSIS/inc \
				CMSIS/device/inc \
				Third_Party/FreeRTOS/org/Source/include \
				Third_Party/FreeRTOS/org/Source/portable/GCC/ARM_CM4F \
				Third_Party/SEGGER/Config/inc \
				Third_Party/SEGGER/OS/inc \
				Third_Party/SEGGER/SEGGER/inc

CC_SOURCE = 	app/src \
				drivers/st/src \
				Third_Party/FreeRTOS/org/Source \
				Third_Party/FreeRTOS/org/Source/portable/GCC/ARM_CM4F \
				Third_Party/FreeRTOS/org/Source/portable/MemMang \
				Third_Party/SEGGER/Config/src \
				Third_Party/SEGGER/OS/src \
				Third_Party/SEGGER/SEGGER/src \

S_SOURCE = 		startup

CC_SOURCES := 	$(shell find $(CC_SOURCE) -maxdepth 1 -name '*.c')
S_SOURCES := 	$(shell find $(S_SOURCE) -maxdepth 1 -name '*.s')

OBJECTS :=		$(addprefix $(OBJDIR)/, $(CC_SOURCES:.c=.o) $(S_SOURCES:.s=.o))

OBJDIRS := 		$(patsubst %, $(OBJDIR)/%, $(CC_SOURCE)) \
				$(patsubst %, $(OBJDIR)/%, $(S_SOURCE))

VPATH += $(CC_SOURCE) $(S_SOURCES)

CC_FLAGS = -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16
CC_FLAGS_OBJS = $(CC_FLAGS) -DSTM32 -DUSE_STDPERIPH_DRIVER -DSTM32F446xx -DSTM32F4 -DSTM32F446RETx -DDEBUG -O0 -g3 -Wall -fmessage-length=0 -ffunction-sections -c -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" 
CC_FLAGS_ELF = $(CC_FLAGS) -T"LinkerScript.ld" -Wl,-Map=output.map -Wl,--gc-sections
CC_PARAMS=$(foreach d, $(CC_INCLUDE), -I$d) 

all: $(OUTPUT).elf

$(OUTPUT).elf: dir $(OBJDIRS) $(OBJECTS) LinkerScript.ld
	@echo 'Building target: $@'
	@echo 'Invoking: MCU GCC Linker'
	$(CC) $(CC_FLAGS_ELF) -o $(BINDIR)/$(OUTPUT).elf $(OBJECTS) -lm
	@echo 'Finished building target: $@'
	@echo ' '
	$(MAKE) --no-print-directory post-build

$(OBJDIR)/%.o: %.s
	@echo 'Building file: $@'
	@echo 'Invoking: C Compiler'
	$(CC) $(CC_PARAMS) $(CC_FLAGS_OBJS) -o $@ $<
	@echo 'Finished building: $@'
	@echo ' '

$(OBJDIR)/%.o: %.c
	@echo 'Building file: $@'
	@echo 'Invoking: C Compiler'
	$(CC) $(CC_PARAMS) $(CC_FLAGS_OBJS) -o $@ $<
	@echo 'Finished building: $@'
	@echo ' '

$(OBJDIRS):
	mkdir -p $@ 

.PHONY: post-build dir clean
post-build:
	-@echo 'Generating binary and Printing size information:'
	arm-none-eabi-objcopy -O binary "$(BINDIR)/$(OUTPUT).elf" "$(BINDIR)/$(OUTPUT).bin"
	arm-none-eabi-size "$(BINDIR)/$(OUTPUT).elf"
	-@echo ' '

dir:
	@echo 'Creat output folders'
	$(MK) $(BINDIR) $(OBJDIR)
	@echo ' '

clean:
	@echo 'Clean output folders'
	$(RM) $(BINDIR)/ $(OBJDIR)/ $(RELEASEDIR)/
	@echo ' '