#ifndef _FLASH_N25Q_H_
#define _FLASH_N25Q_H_

#include <stdint.h>


#define N25Q_PAGE_SIZE 	                   256

#define N25Q_PAGE_TO_ADDR(page)           (page << 8)
#define N25Q_SUBSECTOR_TO_ADDR(subsector) (subsector << 12)
#define N25Q_SECTOR_TO_ADDR(sector)       (sector << 16)

#define WRITE_STATUS_REG_CMD		0x01
#define PAGE_PROGRAM_CMD			0x02
#define READ_CMD 					0x03
#define WRITE_DISABLE_CMD 			0x04
#define READ_STATUS_REG_CMD 		0x05
#define WRITE_ENABLE_CMD 			0x06
#define SUBSECTOR_ERASE_CMD			0x20
#define CLEAR_FLAG_STATUS_REG_CMD	0x50
#define READ_FLAG_STATUS_REG_CMD	0x70
#define BULK_ERASE_CMD				0xC7
#define SECTOR_ERASE_CMD			0xD8
#define WRITE_LOCK_REG_CMD  		0xE5
#define READ_LOCK_REG_CMD   		0xE8
#define READ_ID_CMD 				0x9F


void n25q_init();
void n25q_read_id(uint8_t data[], uint8_t len);
void n25q_read_data(uint8_t data[], uint32_t len, uint32_t addr);
void n25q_subsector_erase(uint32_t subsector);
void n25q_sector_erase(uint32_t sector);
void n25q_page_program(uint8_t data[], uint32_t len, uint32_t page);

#endif
