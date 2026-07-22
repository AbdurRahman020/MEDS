module stopwatch #(
    // clock frequency in Hz (default: 100 MHz)
    parameter CLK_FREQ = 100_000_000
)(
    input  logic clk,
    input  logic rst,

    // bcd outputs for the stopwatch display
    output logic [3:0] minute,
    output logic [3:0] sec_tens,
    output logic [3:0] sec_ones,
    output logic [3:0] tenths
);

    // number of clock cycles required for one-tenth of a second
    localparam integer TICKS_PER_TENTH = CLK_FREQ/10;

    // counts clock cycles until one-tenth of a second has elapsed
    logic [$clog2(TICKS_PER_TENTH)-1:0] tick_counter;
    logic tenth_tick;

    // clock divider: generate a pulse every 0.1 seconds
    always_ff @(posedge clk) begin
        if (rst)
            tick_counter <= 0;
        else if (tick_counter == TICKS_PER_TENTH-1)
            tick_counter <= 0;
        else
            tick_counter <= tick_counter + 1;
    end

    // assert for one clock cycle every tenth of a second
    assign tenth_tick = (tick_counter == TICKS_PER_TENTH-1);

    // detect when the tenths digit rolls over from 9 back to 0
    logic tenths_rollover;
    assign tenths_rollover = tenth_tick && (tenths == 9);

    // increment the tenths digit every tenth of a second
    always_ff @(posedge clk) begin
        if (rst)
            tenths <= 0;
        else if (tenth_tick)
            tenths <= tenths_rollover ? 0 : tenths + 1;
    end

    // detect when the seconds ones digit rolls over from 9 to 0
    logic sec_ones_rollover;
    assign sec_ones_rollover = tenths_rollover && (sec_ones == 9);

    // increment the seconds ones digit every time tenths rolls over
    always_ff @(posedge clk) begin
        if (rst)
            sec_ones <= 0;
        else if (tenths_rollover)
            sec_ones <= sec_ones_rollover ? 0 : sec_ones + 1;
    end

    // detect when the seconds tens digit rolls over from 5 to 0
    logic sec_tens_rollover;
    assign sec_tens_rollover = sec_ones_rollover && (sec_tens == 5);

    // increment the seconds tens digit every 10 seconds
    always_ff @(posedge clk) begin
        if (rst)
            sec_tens <= 0;
        else if (sec_ones_rollover)
            sec_tens <= sec_tens_rollover ? 0 : sec_tens + 1;
    end

    // increment the minute digit every 60 seconds, the minute counter wraps from 9 back to 0
    always_ff @(posedge clk) begin
        if (rst)
            minute <= 0;
        else if (sec_tens_rollover)
            minute <= (minute == 9) ? 0 : minute + 1;
    end

endmodule : stopwatch
