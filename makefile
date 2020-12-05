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
				Third_Party/SEGGER/Config \
				Third_Party/SEGGER/OS \
				Third_Party/SEGGER/SEGGER

CC_SOURCE = 	app/src \
				drivers/st/src \
				Third_Party/FreeRTOS/org/Source \
				Third_Party/FreeRTOS/org/Source/portable/GCC/ARM_CM4F \
				Third_Party/FreeRTOS/org/Source/portable/MemMang \
				Third_Party/SEGGER/Config \
				Third_Party/SEGGER/OS \
				Third_Party/SEGGER/SEGGER \
				Third_Party/SEGGER/SEGGER/Syscalls \

S_SOURCE = 		startup

STA_SOURCE = 	Third_Party/SEGGER/SEGGER/startup

CC_SOURCES := 	$(shell find $(CC_SOURCE) -maxdepth 1 -name '*.c')
S_SOURCES := 	$(shell find $(S_SOURCE) -maxdepth 1 -name '*.s')
STA_SOURCES := 	$(shell find $(STA_SOURCE) -maxdepth 1 -name '*.S')

OBJECTS :=		$(addprefix $(OBJDIR)/, $(CC_SOURCES:.c=.o) $(S_SOURCES:.s=.o) $(STA_SOURCES:.S=.o))

OBJDIRS := 		$(patsubst %, $(OBJDIR)/%, $(CC_SOURCE)) \
				$(patsubst %, $(OBJDIR)/%, $(S_SOURCE)) \
				$(patsubst %, $(OBJDIR)/%, $(STA_SOURCE))

VPATH += $(CC_SOURCE) $(S_SOURCES) $(STA_SOURCES)

CC_FLAGS = -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16 -specs=rdimon.specs -lc -lrdimon
CC_FLAGS_OBJS = -DSTM32 -DUSE_STDPERIPH_DRIVER -DSTM32F446xx -DSTM32F4 -DSTM32F446RETx
CC_FLAGS_ELF = $(CC_FLAGS) -T"LinkerScript.ld" -Wl,-Map=bin/output.map -Wl,--gc-sections
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
	$(CC) $(CC_FLAGS) $(CC_FLAGS_OBJS) $(CC_PARAMS) -DDEBUG -O0 -g3 -Wall -fmessage-length=0 -ffunction-sections -c -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -o $@ $<
	@echo 'Finished building: $@'
	@echo ' '

$(OBJDIR)/%.o: %.S
	@echo 'Building file: $@'
	@echo 'Invoking: C Compiler'
	$(CC) $(CC_FLAGS) $(CC_FLAGS_OBJS) $(CC_PARAMS) -DDEBUG -O0 -g3 -Wall -fmessage-length=0 -ffunction-sections -c -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -o $@ $<
	@echo 'Finished building: $@'
	@echo ' '

$(OBJDIR)/%.o: %.c
	@echo 'Building file: $@'
	@echo 'Invoking: C Compiler'
	$(CC) $(CC_FLAGS) $(CC_FLAGS_OBJS) $(CC_PARAMS) -DDEBUG -O0 -g3 -Wall -fmessage-length=0 -ffunction-sections -c -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -o $@ $<
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
	@echo $(OBJECTS)
	$(MK) $(BINDIR) $(OBJDIR)
	@echo ' '

clean:
	@echo 'Clean output folders'
	$(RM) $(BINDIR)/ $(OBJDIR)/ $(RELEASEDIR)/
	@echo ' '