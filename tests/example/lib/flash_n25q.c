#include <stdint.h>

#include "../include/flash_n25q.h"
#include "../include/spi.h"
#include "../include/xprintf.h"


/* N25Q064特点:
 * 1.总共64Mb大小，即8MB
 * 2.总共128个扇区，每个扇区大小为64KB
 * 3.总共2048个子扇区，每个子扇区大小为4KB
 * 4.总共37768页，每页大小为256B
 * 5.擦除的最小单位是子扇区，编程(写)的最小单位是页，读的最小单位是字节
 */


// 写使能
// 擦除或者编程操作之前必须先发送写使能命令
void n25q_write_enable(uint8_t en)
{
    spi_set_ss(0);

    if (en)
        spi_write_byte(WRITE_ENABLE_CMD);
    else
        spi_write_byte(WRITE_DISABLE_CMD);

    spi_set_ss(1);
}

// 读状态寄存器
uint8_t n25q_read_status_reg()
{
    uint8_t data;

    spi_set_ss(0);

    spi_write_byte(READ_STATUS_REG_CMD);
    data = spi_read_byte();

    spi_set_ss(1);

    return data;
}

// 是否正在擦除或者编程
uint8_t n25q_is_busy()
{
    return (n25q_read_status_reg() & 0x1);
}

void n25q_init()
{
    spi_init();
}

// 读ID号
void n25q_read_id(uint8_t data[], uint8_t len)
{
    spi_set_ss(0);

    spi_write_byte(READ_ID_CMD);
    spi_read_bytes(data, len);

    spi_set_ss(1);
}

// 读数据
// addr: 0, 1, 2, ...
void n25q_read_data(uint8_t data[], uint32_t len, uint32_t addr)
{
    spi_set_ss(0);

    spi_write_byte(READ_CMD);
    spi_write_byte((addr >> 16) & 0xff);
    spi_write_byte((addr >> 8) & 0xff);
    spi_write_byte(addr & 0xff);
    spi_read_bytes(data, len);

    spi_set_ss(1);
}

// 子扇区擦除
// subsector，第几个子扇区: 0 ~ N
void n25q_subsector_erase(uint32_t subsector)
{
    n25q_write_enable(1);

    spi_set_ss(0);

    uint32_t addr = N25Q_SUBSECTOR_TO_ADDR(subsector);

    spi_write_byte(SUBSECTOR_ERASE_CMD);
    spi_write_byte((addr >> 16) & 0xff);
    spi_write_byte((addr >> 8) & 0xff);
    spi_write_byte(addr & 0xff);

    spi_set_ss(1);

    while (n25q_is_busy());

    n25q_write_enable(0);
}

// 扇区擦除
// sector，第几个扇区: 0 ~ N
void n25q_sector_erase(uint32_t sector)
{
    n25q_write_enable(1);

    spi_set_ss(0);

    uint32_t addr = N25Q_SECTOR_TO_ADDR(sector);

    spi_write_byte(SECTOR_ERASE_CMD);
    spi_write_byte((addr >> 16) & 0xff);
    spi_write_byte((addr >> 8) & 0xff);
    spi_write_byte(addr & 0xff);

    spi_set_ss(1);

    while (n25q_is_busy());

    n25q_write_enable(0);
}

// 页编程
// page，第几页: 0 ~ N
void n25q_page_program(uint8_t data[], uint32_t len, uint32_t page)
{
    n25q_write_enable(1);

    spi_set_ss(0);

    uint32_t addr = N25Q_PAGE_TO_ADDR(page);

    spi_write_byte(PAGE_PROGRAM_CMD);
    spi_write_byte((addr >> 16) & 0xff);
    spi_write_byte((addr >> 8) & 0xff);
    spi_write_byte(addr & 0xff);
    spi_write_bytes(data, len);

    spi_set_ss(1);

    while (n25q_is_busy());

    n25q_write_enable(0);
}
