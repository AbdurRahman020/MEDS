#include <stdio.h>
#include <stdint.h>

// UART status flags
#define UART_STATUS_TX_READY   (1u << 0)
#define UART_STATUS_RX_READY   (1u << 1)

// UART peripheral
typedef struct {
    volatile uint32_t control;
    volatile uint32_t status;
    volatile uint32_t tx_data;
    volatile uint32_t rx_data;
} uart_t;


// initialize UART
void uart_init(uart_t *uart) {
    uart->control = 0x01;
    uart->status  = UART_STATUS_TX_READY;
}


// send one character 
void uart_putchar(uart_t *uart, char c) {
    // wait until TX is ready
    while (!(uart->status & UART_STATUS_TX_READY));
    
    // write character to the TX data register
    uart->tx_data = (uint32_t)c;

    // console simulation
    putchar(c);

    // optional: auto carriage return
    if (c == '\n') {
        putchar('\r');
    }
}


// receive one character
char uart_getchar(uart_t *uart) {
    // wait until RX has data
    while (!(uart->status & UART_STATUS_RX_READY));

    char c = (char)(uart->rx_data & 0xFF);

    // clear RX ready flag after reading
    uart->status &= ~UART_STATUS_RX_READY;

    return c;
}


int main(void) {
    uart_t uart0;

    uart_init(&uart0);

    // send string
    const char *msg = "Hello\n";

    while (*msg) {
        uart_putchar(&uart0, *msg++);
    }

    // simulate received data
    uart0.rx_data = 'A';
    uart0.status |= UART_STATUS_RX_READY;

    // read character
    char ch = uart_getchar(&uart0);

    printf("Received: %c\n", ch);

    return 0;
}
