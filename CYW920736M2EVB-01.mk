#
# Copyright 2016-2024, Cypress Semiconductor Corporation (an Infineon company) or
# an affiliate of Cypress Semiconductor Corporation.  All rights reserved.
#
# This software, including source code, documentation and related
# materials ("Software") is owned by Cypress Semiconductor Corporation
# or one of its affiliates ("Cypress") and is protected by and subject to
# worldwide patent protection (United States and foreign),
# United States copyright laws and international treaty provisions.
# Therefore, you may use this Software only as provided in the license
# agreement accompanying the software package from which you
# obtained this Software ("EULA").
# If no EULA applies, Cypress hereby grants you a personal, non-exclusive,
# non-transferable license to copy, modify, and compile the Software
# source code solely for use in connection with Cypress's
# integrated circuit products.  Any reproduction, modification, translation,
# compilation, or representation of this Software except as specified
# above is prohibited without the express written permission of Cypress.
#
# Disclaimer: THIS SOFTWARE IS PROVIDED AS-IS, WITH NO WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, NONINFRINGEMENT, IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. Cypress
# reserves the right to make changes to the Software without notice. Cypress
# does not assume any liability arising out of the application or use of the
# Software or any product or circuit described in the Software. Cypress does
# not authorize its products for use in any products where a malfunction or
# failure of the Cypress product may reasonably be expected to result in
# significant property damage, injury or death ("High Risk Product"). By
# including Cypress's product in a High Risk Product, the manufacturer
# of such system or application assumes all risk of such use and in doing
# so agrees to indemnify Cypress against all liability.
#

ifeq ($(WHICHFILE),true)
$(info Processing $(lastword $(MAKEFILE_LIST)))
endif

#
# Device definition
#
DEVICE=CYW20736A1KML2G
CHIP=20736
CHIP_REV=A1
BLD=A

# CSP baselib and BSP path variables
CY_TARGET_DEVICE?=$(CHIP)$(CHIP_REV)
CY_APP_PATCH_LIBS+=$(CY_$(CY_TARGET_DEVICE)_APP_PATCH_LIBS)
COMPONENTS+=$(CY_TARGET_DEVICE) $(COMPONENTS_$(CY_TARGET_DEVICE))
ifeq ($(SEARCH_$(CY_TARGET_DEVICE)),)
# internal only - app deploys will always initialize this in mtb.mk
SEARCH_$(CY_TARGET_DEVICE)?=$(IN_REPO_BTSDK_ROOT)/wiced_btsdk/dev-kit/baselib/$(CY_TARGET_DEVICE)
SEARCH+=$(SEARCH_$(CY_TARGET_DEVICE))
endif
CY_BSP_PATH?=$(SEARCH_TARGET_$(TARGET))
# ensure the baselib has been instantiated (in case make getlibs had already been performed, but for a BSP with a different CSP
ifneq ("$(wildcard $(SEARCH_$(CY_TARGET_DEVICE))/COMPONENT_$(CY_TARGET_DEVICE))","")
CY_BASELIB_PATH?=$(SEARCH_$(CY_TARGET_DEVICE))/COMPONENT_$(CY_TARGET_DEVICE)
CY_BASELIB_CORE_PATH?=$(SEARCH_core-make)
CY_INTERNAL_BASELIB_PATH?=$(patsubst %/,%,$(CY_BASELIB_PATH))
override CY_DEVICESUPPORT_SEARCH_PATH:=$(call CY_MACRO_SEARCH,devicesupport.xml,$(CY_INTERNAL_BASELIB_PATH))
endif

# declare which stack version to use in COMPONENT folders
COMPONENTS+=btstack_v1

#
# Define the features for this target
#
KITPROG3_BRIDGE=1

# Begin address of flash0, off-chip sflash
CY_FLASH0_BEGIN_ADDR=0xFF000000
# Available flash = 1024k
CY_FLASH0_LENGTH=0x80000
# Entry-point symbol for application
CY_CORE_APP_ENTRY:=spar_crt_setup

#
# TARGET UART parameters
#
# Max. supported baudrate by this platform
CY_CORE_DEFINES+=-DHCI_UART_MAX_BAUD=4000000
# default baud rate is 3M, that is the max supported on macOS
CY_CORE_DEFINES+=-DHCI_UART_DEFAULT_BAUD=3000000
ifneq ($(KITPROG3_USE_1_STOP_BIT),1)
# need to set 2 stop bits for KitProg3 at 3M baud rate
CY_CORE_DEFINES+=-DKITPROG3_USE_2_STOP_BITS
endif

#
# pins supporting SWD hardware debugging
#
ifeq ($(ENABLE_DEBUG),1)
CY_CORE_DEFINES+=-DSWD_CLK=SWDCK_ON_P14
CY_CORE_DEFINES+=-DSWD_IO=SWDIO_ON_P15
endif

#
# Patch variables
#
CY_CORE_PATCH=$(CY_INTERNAL_BASELIB_PATH)/internal/20736A1/patches/patch.elf
CY_CORE_CGSLIST=$(CY_INTERNAL_BASELIB_PATH)/internal/20736A1/patches/patch.cgs

CY_CORE_PATCH_CFLAGS=$(CY_INTERNAL_BASELIB_PATH)/internal/20736A1/gcc/20736A1.cflag
CY_CORE_PATCH_LIB_PATH=libraries/prebuilt

#
# Variables for pre-build and post-build processing
#
CY_CORE_HDF=$(CY_INTERNAL_BASELIB_PATH)/internal/20736A1/configdef20736a1.hdf
CY_CORE_HCI_ID=$(CY_INTERNAL_BASELIB_PATH)/platforms/IDFILE.txt
CY_CORE_BTP=$(CY_INTERNAL_BASELIB_PATH)/platforms/20736_SFLASH.btp

CY_CORE_CGSLIST+=$(CY_INTERNAL_BASELIB_PATH)/platforms/CYW20736A1.cgs

CY_CORE_MINIDRIVER=$(CY_INTERNAL_BASELIB_PATH)/platforms/minidriver-20732-uart.hex

#
# read in BTP file as single source of flash layout information
#
define \n


endef

define extract_btp_file_value
$(patsubst $1=%,%,$(filter $1%,$2))
endef

# these make targets do not need this data and don't work if importing an app
# that has not yet run make getlibs, so skip it
ifeq ($(filter import_deps getlibs get_app_info,$(MAKECMDGOALS)),)

# override core-make buggy CY_SPACE till it's fixed
CY_EMPTY=
CY_SPACE=$(CY_EMPTY) $(CY_EMPTY)

# split up btp file into "x=y" text
CY_BT_FILE_TEXT:=$(shell cat -e $(CY_CORE_BTP))
CY_BT_FILE_TEXT:=$(subst $(CY_SPACE),,$(CY_BT_FILE_TEXT))
CY_BT_FILE_TEXT:=$(subst ^M,,$(CY_BT_FILE_TEXT))
CY_BT_FILE_TEXT:=$(patsubst %$(\n),% ,$(CY_BT_FILE_TEXT))
CY_BT_FILE_TEXT:=$(subst $$,$(CY_SPACE),$(CY_BT_FILE_TEXT))

ifeq ($(CY_BT_FILE_TEXT),)
$(error Failed to parse BTP variables from file: $(CY_CORE_BTP))
endif

SS_LOCATION = $(call extract_btp_file_value,DLConfigSSLocation,$(CY_BT_FILE_TEXT))
VS_LOCATION = $(call extract_btp_file_value,DLConfigVSLocation,$(CY_BT_FILE_TEXT))
VS_LENGTH = $(call extract_btp_file_value,DLConfigVSLength,$(CY_BT_FILE_TEXT))
DS_LOCATION = $(call extract_btp_file_value,ConfigDSLocation,$(CY_BT_FILE_TEXT))
DS2_LOCATION = $(call extract_btp_file_value,ConfigDS2Location,$(CY_BT_FILE_TEXT))

endif # end filter import_deps getlibs get_app_info

# OTA
ifeq ($(OTA_FW_UPGRADE),1)
CY_APP_OTA=OTA
CY_APP_OTA_DEFINES=-DOTA_FW_UPGRADE=1
ifeq ($(CY_APP_SECURE_OTA_FIRMWARE_UPGRADE),1)
CY_APP_OTA_DEFINES+=-DOTA_SECURE_FIRMWARE_UPGRADE
endif
endif

# use flash offset and length to limit xip range
CY_CORE_LD_DEFS+=FLASH0_BEGIN_ADDR=$(CY_FLASH0_BEGIN_ADDR)
CY_CORE_LD_DEFS+=FLASH0_LENGTH=$(CY_FLASH0_LENGTH)

# defines necessary for flash layout
CY_CORE_DEFINES+=-DSS_LOCATION=$(SS_LOCATION) -DVS_LOCATION=$(VS_LOCATION) -DDS_LOCATION=$(DS_LOCATION) -DDS2_LOCATION=$(DS2_LOCATION)

# others are correct
CY_CORE_LD_DEFS+=\
	SRAM_BEGIN_ADDR=0x00200000 \
	SRAM_LENGTH=0x0000F000 \
	NUM_PATCH_ENTRIES=64
