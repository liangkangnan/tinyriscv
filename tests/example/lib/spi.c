#include <stdint.h>

#include "../include/spi.h"


void spi_init()
{
    SPI_REG(SPI_CTRL) = 0x06;              // CPOL = 1, CPHA = 1
}

void spi_set_ss(uint8_t level)
{
    if (!level)
        SPI_REG(SPI_CTRL) |= 1 << 3;
    else
        SPI_REG(SPI_CTRL) &= ~(1 << 3);
}

void spi_write_byte(uint8_t data)
{
    SPI_REG(SPI_DATA) = data;
    SPI_REG(SPI_CTRL) |= 1 << 0;           // start
    while (SPI_REG(SPI_STATUS) & 0x1);     // wait transfer complete
}

void spi_write_bytes(uint8_t data[], uint32_t len)
{
    uint32_t i;

    for (i = 0; i < len; i++)
        spi_write_byte(data[i]);
}

uint8_t spi_read_byte()
{
    uint8_t data;

    SPI_REG(SPI_CTRL) |= 1 << 0;           // start
    while (SPI_REG(SPI_STATUS) & 0x1);     // wait transfer complete
    data = SPI_REG(SPI_DATA) & 0xff;       // readback data

    return data;
}

void spi_read_bytes(uint8_t data[], uint32_t len)
{
    uint32_t i;

    for (i = 0; i < len; i++)
        data[i] = spi_read_byte();
}


//--------SPI2
void spi2_init()
{
    // SPI_REG(SPI2_CTRL) = 0x06;              // CPOL = 1, CPHA = 1
    SPI_REG(SPI2_CTRL) = 0x02;              // CPOL = 1, CPHA = 0
    SPI_REG(SPI2_CTRL) |= 0xFA00;              
}

void spi2_set_ss(uint8_t level)
{
    if (!level)
        SPI_REG(SPI2_CTRL) |= 1 << 3;
    else
        SPI_REG(SPI2_CTRL) &= ~(1 << 3);
}

void spi2_write_byte(uint8_t data)
{
    SPI_REG(SPI2_DATA) = data;
    SPI_REG(SPI2_CTRL) |= 1 << 0;           // start
    while (SPI_REG(SPI2_STATUS) & 0x1);     // wait transfer complete
}

void spi2_write_bytes(uint8_t data[], uint32_t len)
{
    uint32_t i;

    for (i = 0; i < len; i++)
        spi2_write_byte(data[i]);
}

uint8_t spi2_read_byte()
{
    uint8_t data;

    SPI_REG(SPI2_CTRL) |= 1 << 0;           // start
    while (SPI_REG(SPI2_STATUS) & 0x1);     // wait transfer complete
    data = SPI_REG(SPI2_DATA) & 0xff;       // readback data

    return data;
}

void spi2_read_bytes(uint8_t data[], uint32_t len)
{
    uint32_t i;

    for (i = 0; i < len; i++)
        data[i] = spi2_read_byte();
}

uint8_t spi2_write_read_byte(uint8_t data_out)
{
    uint8_t data_in;

    SPI_REG(SPI2_DATA) = data_out;
    SPI_REG(SPI2_CTRL) |= 1 << 0;           // start
    while (SPI_REG(SPI2_STATUS) & 0x1);     // wait transfer complete
    data_in = SPI_REG(SPI2_DATA) & 0xff;       // readback data

    return data_in;
}