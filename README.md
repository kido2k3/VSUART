<div align="center">

<img src="./assets/vsuart_logo.png" width="120" alt="VSUART Logo"/>

# VSUART

### Vietnamese Systemware UART IP

A reusable UART IP and UVM verification environment developed by VS Team

<br>

![SystemVerilog](https://img.shields.io/badge/SystemVerilog-8A2BE2?style=for-the-badge)
![Bash](https://img.shields.io/badge/Verilog-4EAA25?style=for-the-badge&logoColor=white)
![UVM](https://img.shields.io/badge/UVM-FF6F00?style=for-the-badge)
![SVA](https://img.shields.io/badge/SVA-1E90FF?style=for-the-badge)

<br>

![UART](https://img.shields.io/badge/UART-Verified-success?style=for-the-badge)
![APB](https://img.shields.io/badge/APB_Slave-Supported-success?style=for-the-badge)
![RAL](https://img.shields.io/badge/UVM--RAL-Supported-orange?style=for-the-badge)
![Regression](https://img.shields.io/badge/Regression-Passing-brightgreen?style=for-the-badge)
![Coverage](https://img.shields.io/badge/Functional_Coverage-0%25-brightgreen?style=for-the-badge)

</div>

---

# 📖 Overview (T.B.D)

VSUART is a configurable UART IP developed in SystemVerilog and verified using the UVM methodology.

The project contains:

- UART RTL Design
- APB Slave Register Interface
- UVM Testbench
- UVM Register Model (RAL)
- Assertion-Based Verification (SVA)
- Functional Coverage
- Automated Regression Flow

## RTL Features (T.B.D)
- Configurable Baudrate Divider
- UART TX/RX Engine
- Interrupt Generation
- APB Slave Interface
- Configurable Data Width
- Parity Support
- FIFO Support

add architechture diagram here
---
## Verification Features (T.B.D)

- APB Agent
- UART Agent
- UVM Scoreboard
- UVM Register Model
- Assertions (SVA)
- Functional Coverage
- Regression Automation

add testbench architechture diagram here
---

# 📁 Project Structure (T.B.D)

```text
copy from tree
```

### rtl/
RTL implementation of UART IP.

### tb/
UVM verification environment.

### assertion/
SystemVerilog Assertions used for protocol and functional checking.

### coverage/
Functional coverage models and covergroups.

### script/
Simulation and regression automation scripts.

### regression/
Regression testlists and reports.

### doc/
Design specification, verification plan, and architecture documents.

---

# 🚀 Quick Start (T.B.D)

## Build (T.B.D)

```bash
./run.sh -comp
```

## Run Single Test (T.B.D)

```bash
./run.sh -test uart_tx_test
```

## Run with Waveform (T.B.D)

```bash
./run.sh -test uart_tx_test -wave
```

## Run Regression (T.B.D)

```bash
./run.sh -regress
```
## Lint check
```
verilator -Wall --lint-only -f ./src_file.f
```
---
# 📊 Test Results (T.B.D)

## 🧪 Supported Tests (T.B.D)
[pass]: https://img.shields.io/badge/PASS-brightgreen
[fail]: https://img.shields.io/badge/FAIL-red
| Test Name |  Purpose | Status |
|------------|--|--------|
| `uart_reset_test` | Verify DUT reset behavior and default register values. | ![][pass] |
| `uart_tx_test` | Verify UART transmission path functionality. | ![][fail] |
| `uart_rx_test` | Verify UART reception path functionality. | ![][pass] |
| `uart_interrupt_test` | Verify interrupt generation and clearing mechanism. | ![][fail] |
| `uart_fifo_test` | Verify TX/RX FIFO functionality, overflow and underflow scenarios. | ![][fail] |
| `uart_parity_test` | Verify parity generation and parity error detection. |![][fail] |
| `uart_random_test` | Randomized verification covering multiple UART configurations and corner cases. |![][pass] |
## Coverage Summary (T.B.D)

| Coverage Type | Result |
|---------------|---------|
| Functional Coverage | 95% |
| Register Coverage | 100% |
| Assertion Coverage | PASS |

## Regression Summary (T.B.D)

```text
Total Tests : XX
Passed      : XX
Failed      : 0

Pass Rate   : 100%
```
---
# 💬 Feedback (T.B.D)

Contributions, bug reports, and suggestions are welcome.

If you have any questions or find issues, please create a GitHub Issue.

Please include:

- Test name
- Simulator version
- Error log
- Waveform (if available)
- Reproduction steps
---
# 📜 License (T.B.D)

This project is licensed under the MIT License.

See LICENSE for more information.
