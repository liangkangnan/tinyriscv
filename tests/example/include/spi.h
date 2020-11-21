#ifndef _SPI_H_
#define _SPI_H_

#define SPI_BASE      (0x50000000)
#define SPI_CTRL      (SPI_BASE + (0x00))
#define SPI_DATA      (SPI_BASE + (0x04))
#define SPI_STATUS    (SPI_BASE + (0x08))

#define SPI_REG(addr) (*((volatile uint32_t *)addr))

void spi_init();
void spi_set_ss(uint8_t level);
void spi_write_byte(uint8_t data);
void spi_write_bytes(uint8_t data[], uint32_t len);
uint8_t spi_read_byte();
void spi_read_bytes(uint8_t data[], uint32_t len);

#endif
