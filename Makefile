# The Basics
# -------------------------------------------------------------------------------------------------------------
BOARD := adafruit_feather_m0
DEVICE := ttyACM0
TARGET := clearair
BAUD := 9600

SOURCES := $(wildcard $(addprefix src/, *.c *.cpp))
HEADERS :=  $(wildcard $(addprefix src/, *.h))
OUTPUT := bin/deploy

# Dependencies & tooling
# -------------------------------------------------------------------------------------------------------------
DEPENDENCIES_DIR := deps
PLATFORM_DIR := $(DEPENDENCIES_DIR)/arm

CC := $(DEPENDENCIES_DIR)/gcc-arm/bin/arm-none-eabi-gcc
CPPC := $(DEPENDENCIES_DIR)/gcc-arm/bin/arm-none-eabi-g++
AR := $(DEPENDENCIES_DIR)/gcc-arm/bin/arm-none-eabi-ar
OBJCOPY := $(DEPENDENCIES_DIR)/gcc-arm/bin/arm-none-eabi-objcopy
UPLOADER := $(DEPENDENCIES_DIR)/bossac/bossac

# Board info
# -------------------------------------------------------------------------------------------------------------
GET_BOARDS_PARAM = $(shell sed -ne "s/$(BOARD).$(1)=\(.*\)/\1/p" $(PLATFORM_DIR)/boards.txt)

BOARD_BOARD := $(call GET_BOARDS_PARAM,build.board)
BOARD_BOOTLOADER_FILE := $(call GET_BOARDS_PARAM,bootloader.file)
BOARD_BUILD_FCPU := $(call GET_BOARDS_PARAM,build.f_cpu)
BOARD_BUILD_MCU := $(call GET_BOARDS_PARAM,build.mcu)
BOARD_BUILD_VARIANT := $(call GET_BOARDS_PARAM,build.variant)
BOARD_LD_SCRIPT := $(call GET_BOARDS_PARAM,build.ldscript)
BOARD_USB_MANUFACTURER := $(call GET_BOARDS_PARAM,build.usb_manufacturer)
BOARD_USB_PID := $(call GET_BOARDS_PARAM,build.pid)
BOARD_USB_PRODUCT := $(call GET_BOARDS_PARAM,build.usb_product)
BOARD_USB_VID := $(call GET_BOARDS_PARAM,build.vid)

# The variant file for the board contains essential information specific to the device we're compiling for
SOURCES += $(PLATFORM_DIR)/variants/$(BOARD_BUILD_VARIANT)/variant.cpp

OBJECTS := $(addsuffix .o, $(basename $(SOURCES)))
COMPILED_OBJECTS := $(addprefix $(OUTPUT)/, $(addsuffix .o, $(basename $(SOURCES))))

# Flags
# -------------------------------------------------------------------------------------------------------------
CFLAGS := -mcpu=$(BOARD_BUILD_MCU) -mthumb -c -g -Os -w -std=gnu11 -ffunction-sections -fdata-sections \
	-nostdlib --param max-inline-insns-single=500 -MMD
CPPFLAGS := -mcpu=$(BOARD_BUILD_MCU) -mthumb -c -g -Os -w -std=gnu++11 -ffunction-sections -fdata-sections \
	-fno-threadsafe-statics -fno-rtti -fno-exceptions -nostdlib --param max-inline-insns-single=500 -MMD
ASMFLAGS := -c -g -x assembler-with-cpp
ELFFLAGS := -Os -Wl,--gc-sections -save-temps --specs=nano.specs --specs=nosys.specs -mcpu=$(BOARD_BUILD_MCU) \
	-mthumb -Wl,--cref -Wl,--check-sections -Wl,--gc-sections -Wl,--unresolved-symbols=report-all \
	-Wl,--warn-common -Wl,--warn-section-align

# Defines
# -------------------------------------------------------------------------------------------------------------
DEFINES := -DF_CPU=$(BOARD_BUILD_FCPU) -DARDUINO=10605 -DARDUINO_$(BOARD_BOARD) -DARDUINO_ARCH_SAMD \
	-D__SAMD21G18A__ -DUSB_VID=$(BOARD_USB_VID) -DUSB_PID=$(BOARD_USB_PID) -DUSBCON \
	-DUSB_MANUFACTURER=\"$(BOARD_USB_MANUFACTURER)\" -DUSB_PRODUCT=\"$(BOARD_USB_PRODUCT)\"

# Includes
# -------------------------------------------------------------------------------------------------------------
INCLUDE_DIRS := lib/ \
	$(wildcard lib/*) \
	$(DEPENDENCIES_DIR)/cmsis/CMSIS/Include/ \
	$(DEPENDENCIES_DIR)/cmsis/Device/ATMEL/ \
	$(PLATFORM_DIR)/cores/arduino \
	$(PLATFORM_DIR)/variants/$(BOARD_BUILD_VARIANT) \
	$(PLATFORM_DIR)/libraries/SPI \
	$(PLATFORM_DIR)/libraries/Wire

# Add the include flag before each include
INCLUDES := $(foreach dir, $(INCLUDE_DIRS), \
	$(addprefix -I, $(dir)))

# Project Libraries
# -------------------------------------------------------------------------------------------------------------
LIBRARY_SEARCH_PATHS ?= lib $(PLATFORM_DIR)/libraries

# Search the headers for what libraries are included
FOUND_LIBRARIES := $(filter $(notdir $(wildcard $(addsuffix /*, $(LIBRARY_SEARCH_PATHS)))), \
	$(shell sed -ne "s/^ *\# *include *[<\"]\(.*\)\.h[>\"]/\1/p" $(HEADERS)))

# Add the path to the found libraries
LIBRARY_DIRS := $(foreach lib, $(FOUND_LIBRARIES), \
	$(firstword $(wildcard $(addsuffix /$(lib), $(LIBRARY_SEARCH_PATHS)))))

# Explicitly add everything in lib/
EXPLICIT_LIBRARIES = $(notdir $(wildcard lib/*))

LIBRARY_DIRS += $(foreach lib, $(EXPLICIT_LIBRARIES), \
	$(shell find lib/$(lib) -type d))

# Platform Libraries
# -------------------------------------------------------------------------------------------------------------
ARDUINOCOREDIR := $(PLATFORM_DIR)/cores/arduino/ \
	$(PLATFORM_DIR)/cores/arduino/USB/ \
	$(PLATFORM_DIR)/cores/arduino/avr/

# Link all the platform libraries into a single archive
CORE_LIB := $(OUTPUT)/core.a
CORE_LIB_OBJECTS := $(foreach dir, $(ARDUINOCOREDIR) $(LIBRARY_DIRS), \
	$(patsubst %, $(OUTPUT)/%.o, $(wildcard $(addprefix $(dir)/, *.c *.cpp *.S))))

# Recipes
# -------------------------------------------------------------------------------------------------------------

.PHONY:	all target upload size console clean test

all: target

target: $(TARGET).bin

upload:
	$(UPLOADER) -i -d --port=$(DEVICE) -U true -i -e -w -v $(OUTPUT)/$(TARGET).bin -R

size: $(TARGET).elf
	echo && avr-size $(OUTPUT)/$(TARGET).elf

console:
	screen /dev/$(DEVICE) $(BAUD)

$(TARGET).bin: $(TARGET).elf
	$(OBJCOPY) -O binary $(OUTPUT)/$< $(OUTPUT)/$@

$(TARGET).elf: $(CORE_LIB) $(OBJECTS)
	$(CC) -L$(OUTPUT) -T$(PLATFORM_DIR)/variants/$(BOARD_BUILD_VARIANT)/$(BOARD_LD_SCRIPT) \
		-Wl,-Map,$(OUTPUT)/$(TARGET).map $(ELFFLAGS) -o $(OUTPUT)/$@ $(COMPILED_OBJECTS) \
		-Wl,--start-group -lm $(CORE_LIB) -Wl,--end-group

# Build the source files
# -------------------------------------------------------------------------------------------------------------

%.o: %.c
	mkdir -p $(OUTPUT)$(dir $<)
	$(CC) $(CFLAGS) $(PROJECT) $(DEFINES) $(INCLUDES) -o $(OUTPUT)/$@ $<

%.o: %.cpp
	mkdir -p $(OUTPUT)/$(dir $<)
	$(CPPC) $(CPPFLAGS) $(PROJECT) $(DEFINES) $(INCLUDES) -o $(OUTPUT)/$@ $<

# Build the core library files
# -------------------------------------------------------------------------------------------------------------

$(CORE_LIB): $(CORE_LIB_OBJECTS)
	$(AR) rcs $@ $?

$(OUTPUT)/%.c.o: %.c
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(PROJECT) $(DEFINES) $(INCLUDES) -o $@ $<

$(OUTPUT)/%.cpp.o: %.cpp
	mkdir -p $(dir $@)
	$(CPPC) $(CPPFLAGS) $(PROJECT) $(DEFINES) $(INCLUDES) -o $@ $<

$(OUTPUT)/%.S.o: %.S
	mkdir -p $(dir $@)
	$(CC) $(CPPFLAGS) $(PROJECT) $(DEFINES) $(INCLUDES) -o $@ $<

clean:
	rm -f $(COMPILED_OBJECTS)
	rm -f $(OUTPUT)/$(TARGET).elf $(OUTPUT)/$(TARGET).bin $(CORE_LIB) $(OUTPUT)/$(TARGET).map
	rm -rf $(OUTPUT)/src $(OUTPUT)/lib
