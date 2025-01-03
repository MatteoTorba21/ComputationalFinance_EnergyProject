# ComputationalFinance_EnergyProject
This repository contains a MATLAB library for calibrating forward models and simulating European option prices using arithmetic models. The project focuses on electricity swap contracts in the French power market.

## Overview

The main objectives of this project are:
1. **Calibrate an additive Ornstein-Uhlenbeck (OU) model** driven by two Inverse Gaussian (IG) processes for French power futures.
2. **Simulate European option prices** via Monte Carlo methods using the calibrated models.
3. **Calibrate an additive Ornstein-Uhlenbeck (OU) model** driven by a Gaussian process and simulate the European option price.

## Key Features

### Additive OU Model with Inverse Gaussian Drivers
- **Spot Price Model**: Incorporates yearly seasonality with parameters calibrated to match the French electricity swap data.
- **Forward Price Computation**: Derived under the risk-neutral measure using Esscher transform coefficients.
- **Swap Price Analysis**: Modeled using continuous monitoring and settlement at the period's end.

### Calibration
- **Parameters Calibrated**:
  - OU model parameters: `β1`, `β2`, `η1`, `η2`
  - Seasonal components: `A`, `B`, `C`
  - IG process parameter
- **Input Data**: Futures prices from the French electricity market.
- **Results Evaluation**: Assess calibration reliability, speed, and model parsimony.

### Simulation and Pricing
- **Monte Carlo Simulation**: Used to price European put options on 2028 futures with strike prices in the range of 200–400 and a 2-year maturity.
- **Model Comparison**: Results compared between:
  - Arithmetic model based on IG-driven OU processes.
  - Arithmetic model based on Gaussian OU processes.

### Files and Resources
MATLAB Code: Contains scripts for the calibration of the Arithmetic Models, and for the pricing.

Project Report: A comprehensive document detailing the theoretical framework, methodologies, results, and discussions.

