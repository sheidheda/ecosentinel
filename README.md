# EcoSentinel: Secure Decentralized Ecosystem Health Monitoring Contract

## Overview
EcoSentinel is a decentralized smart contract designed to facilitate secure and transparent environmental monitoring using blockchain technology. It allows stakeholders to submit, validate, and reward contributions for environmental sensor data. This contract aims to promote accuracy and incentivize participation in ecosystem health monitoring.  

---

## Features

1. **Sensor Registration**  
   - Stakeholders can register sensors with initial data, ensuring a minimum stake is provided to ensure commitment.

2. **Data Submission**  
   - Contributors can submit environmental data points tied to a specific sensor and timestamp.

3. **Data Verification**  
   - Data submitted by contributors can be verified by others. Verified data earns rewards, while invalid data leads to penalties.

4. **Reward Pool Management**  
   - A reward pool incentivizes contributors. The pool can be replenished by the contract owner.

5. **Security and Transparency**  
   - Stake-based mechanisms discourage fraudulent data submissions. All transactions and data verifications are recorded on the blockchain for transparency.

---

## Contract Constants and Variables

### Constants
- **`contract-owner`**: Address of the contract owner.
- **`minimum-stake`**: Minimum STX stake required for data submission (500 STX).
- **`max-data-length`**: Maximum length for a data point string (256 characters).
- **`max-reward-pool`**: Maximum reward pool size (1,000,000 STX).
- **Error Codes**: 
  - `err-unauthorized (u100)`: Unauthorized action.
  - `err-invalid-data (u101)`: Data not found or invalid.
  - `err-insufficient-stake (u102)`: Insufficient stake balance.
  - `err-already-verified (u103)`: Duplicate data verification.
  - `err-invalid-input (u104)`: Invalid input provided.

### Variables
- **`reward-pool`**: Tracks the current reward pool for contributors (default: 10,000 STX).

---

## Functions

### Public Functions

1. **Register Sensor**  
   `register-sensor(sensor-id uint, initial-data (string-utf8 256))`  
   - Registers a new environmental sensor with an initial data point.
   - Locks the contributor's stake in the contract.

2. **Submit Sensor Data**  
   `submit-sensor-data(sensor-id uint, data-point (string-utf8 256))`  
   - Allows contributors to submit data tied to a sensor and timestamp.  
   - Requires a minimum stake to ensure quality submissions.

3. **Verify Sensor Data**  
   `verify-sensor-data(sensor-id uint, timestamp uint, is-valid bool)`  
   - Allows contributors to validate submitted data.  
   - Rewards valid data and penalizes invalid submissions.

4. **Contribute to Reward Pool**  
   `contribute-to-reward-pool(amount uint)`  
   - Allows the contract owner to add funds to the reward pool.

### Read-Only Functions

1. **Check Data Verification Status**  
   `is-data-verified(sensor-id uint, timestamp uint)`  
   - Returns the verification status (`true`/`false`) for a specific data point.

---

## Usage Guide

### Registering a Sensor
1. Call `register-sensor` with a unique `sensor-id` and `initial-data`.
2. Ensure your account has at least 500 STX to lock as a stake.

### Submitting Sensor Data
1. Call `submit-sensor-data` with a valid `sensor-id` and `data-point`.
2. Ensure no duplicate submissions for the same timestamp.

### Verifying Data
1. Call `verify-sensor-data` with the `sensor-id`, `timestamp`, and `is-valid` flag.
2. If valid, the contributor receives their stake back plus a reward.
3. Invalid submissions result in penalties.

### Managing the Reward Pool
- The contract owner can call `contribute-to-reward-pool` to replenish the reward pool.

### Querying Data Verification Status
- Use `is-data-verified` to check if a specific data point has been verified.

---

## Error Handling
- **Unauthorized Actions**: Only the contract owner can perform admin functions.
- **Invalid Inputs**: Ensure sensor IDs, data points, and other parameters meet validation requirements.
- **Insufficient Stake**: Ensure sufficient balance for stakes before registration or submission.

---

## Technical Details

### Data Structures
- **Sensor Data**: Stores data points, contributor details, stake amount, and verification status.
- **Data Verifications**: Tracks the count of verifications and final status for each data point.

### Stake and Rewards
- Contributors must provide a minimum stake for participation.
- Verified data is rewarded with a portion of the reward pool.
- Invalid data results in partial forfeiture of the stake.

---

## Deployment and Testing
1. Deploy the contract on the Stacks blockchain.
2. Test functionalities such as registration, data submission, and verification using the Clarity developer tools.

---

## Future Enhancements
- Implement additional verification mechanisms (e.g., multi-sig validation).
- Integrate external data sources or oracles for automatic validation.
- Provide a frontend interface for easier interaction with the contract.

---

EcoSentinel ensures a secure and decentralized approach to environmental monitoring, fostering collaboration and trust in ecosystem health management.