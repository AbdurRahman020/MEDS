# SystemVerilog Workshop

Digital design workshop tasks — each folder is a self-contained module with
its own documentation, RTL, and testbench.

## Structure

```
SYSTEMVERILOG-WORKSHOP/
├── button_parser_fsm/
│   ├── docs/     block diagram + state diagram (.drawio / .png)
│   ├── rtl/      button_parser.sv
│   └── tb/       tb_button_parser.sv
├── pwm_generator/
│   ├── docs/     block diagram (.drawio / .png)
│   ├── rtl/      pwm_gen.sv
│   └── tb/       tb_pwm_gen.sv
└── smart_vending_machine_controller/
    ├── docs/     block diagram, datapath diagram, FSM diagram
    ├── rtl/      controller.sv, datapath.sv, vending_machine.sv
    └── tb/       tb_vending_machine.sv
```

## Tasks

### 1. button_parser_fsm
2-state Mealy FSM that turns a raw button input into a one-cycle
`press_event` pulse on each press. No debounce logic — intended as a
minimal FSM design exercise, not a production-ready input handler.

### 2. pwm_generator
8-bit free-running counter driving a fixed-duty-cycle PWM output
(`pwm` high while `count < 128`), giving a 50% duty cycle over a
256-cycle period.

### 3. smart_vending_machine_controller
Full vending machine design for 4 products (water, juice, chocolate,
chips): coin acceptance with a max-balance clamp, purchase validation
(stock + balance checks), change calculation, stock tracking with
refill, and a hierarchical Moore FSM controller (Master + Coin/Product/
Change sub-FSMs). Testbench is randomized and self-checking — it drives
random coin/selection/cancel sequences against a software scoreboard
until target products run out of stock, then restocks.
