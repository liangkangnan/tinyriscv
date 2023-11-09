#ifndef _SPI_H_
#define _SPI_H_

#include <stdint.h>

#define SPI_BASE      (0x30000000)
#define SPI_CTRL      (SPI_BASE + (0x20))
#define SPI_DATA      (SPI_BASE + (0x24))
#define SPI_STATUS    (SPI_BASE + (0x28))
#define SPI2_CTRL      (SPI_BASE + (0x30))
#define SPI2_DATA      (SPI_BASE + (0x34))
#define SPI2_STATUS    (SPI_BASE + (0x38))

#define SPI_REG(addr) (*((volatile uint32_t *)addr))

void spi_init();
void spi_set_ss(uint8_t level);
void spi_write_byte(uint8_t data);
void spi_write_bytes(uint8_t data[], uint32_t len);
uint8_t spi_read_byte();
void spi_read_bytes(uint8_t data[], uint32_t len);

void spi2_init();
void spi2_set_ss(uint8_t level);
void spi2_write_byte(uint8_t data);
void spi2_write_bytes(uint8_t data[], uint32_t len);
uint8_t spi2_read_byte();
void spi2_read_bytes(uint8_t data[], uint32_t len);
uint8_t spi2_write_read_byte(uint8_t);

#endif
