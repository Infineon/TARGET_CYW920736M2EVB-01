#ifndef _PLATFORM_H_
#define _PLATFORM_H_
/*
 * Copyright 2016-2022, Cypress Semiconductor Corporation (an Infineon company) or
 * an affiliate of Cypress Semiconductor Corporation.  All rights reserved.
 *
 * This software, including source code, documentation and related
 * materials ("Software") is owned by Cypress Semiconductor Corporation
 * or one of its affiliates ("Cypress") and is protected by and subject to
 * worldwide patent protection (United States and foreign),
 * United States copyright laws and international treaty provisions.
 * Therefore, you may use this Software only as provided in the license
 * agreement accompanying the software package from which you
 * obtained this Software ("EULA").
 * If no EULA applies, Cypress hereby grants you a personal, non-exclusive,
 * non-transferable license to copy, modify, and compile the Software
 * source code solely for use in connection with Cypress's
 * integrated circuit products.  Any reproduction, modification, translation,
 * compilation, or representation of this Software except as specified
 * above is prohibited without the express written permission of Cypress.
 *
 * Disclaimer: THIS SOFTWARE IS PROVIDED AS-IS, WITH NO WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, NONINFRINGEMENT, IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. Cypress
 * reserves the right to make changes to the Software without notice. Cypress
 * does not assume any liability arising out of the application or use of the
 * Software or any product or circuit described in the Software. Cypress does
 * not authorize its products for use in any products where a malfunction or
 * failure of the Cypress product may reasonably be expected to result in
 * significant property damage, injury or death ("High Risk Product"). By
 * including Cypress's product in a High Risk Product, the manufacturer
 * of such system or application assumes all risk of such use and in doing
 * so agrees to indemnify Cypress against all liability.
 */


/** @file
*
* This file provides definitions for the CYW920732M2EVB-01 platform
*
*/

#define BLE_P2

/*
 * GPIO settings
 */
#define GPIO_PIN_BUTTON      	4
#define GPIO_SETTINGS_BUTTON 	(GPIO_INPUT  | GPIO_INIT_HIGH | GPIO_BUTTON | GPIO_INT)

#define GPIO_PIN_WP          	1
#define GPIO_SETTINGS_WP     	(GPIO_OUTPUT | GPIO_INIT_LOW  | GPIO_WP)

#define GPIO_PIN_LED            26
#define GPIO_SETTINGS_LED    	(GPIO_OUTPUT | GPIO_INIT_HIGH | GPIO_LED)

#define GPIO_PIN_BATTERY	 	15
#define GPIO_SETTINGS_BATTERY	(GPIO_INPUT  | GPIO_INIT_LOW  | GPIO_BAT)

#define GPIO_PIN_BUZZER         28
#define GPIO_SETTINGS_BUZZER	(GPIO_OUTPUT | GPIO_INIT_LOW | GPIO_BUZ)

#define GPIO_PIN_UART_TX		24
#define GPIO_PIN_UART_RX		25

#endif
