# Bitcoin Multi-Signature Wallet Smart Contract

## Overview

This is a Clarity smart contract implementing a multi-signature wallet. The contract allows a set of owners (N) to collectively approve transactions, requiring a minimum number of signatures (M) before execution. The contract supports owner management, transaction signing, execution, and cancellation.

## Features

- **Multi-Signature Transactions**: Requires M-of-N owners to approve transactions before execution.
- **Transaction Management**: Owners can submit, sign, execute, or cancel transactions.
- **Owner Management**: Owners can be added or removed through a multi-signature process.
- **Configurable Signature Threshold**: The required number of signatures can be updated with approval.
- **Security Checks**: Ensures only owners can sign or execute transactions and prevents unauthorized access.

## Constants (Error Codes)

| Constant                  | Error Code | Description |
|---------------------------|------------|-------------|
| ERR-NOT-AUTHORIZED        | `u1`       | Caller is not an authorized owner. |
| ERR-INVALID-SIGNATURE     | `u2`       | Signature is invalid. |
| ERR-ALREADY-SIGNED        | `u3`       | Owner has already signed this transaction. |
| ERR-INSUFFICIENT-SIGNATURES | `u4`    | Not enough signatures to execute transaction. |
| ERR-INVALID-THRESHOLD     | `u5`       | Threshold is invalid. |
| ERR-TX-NOT-FOUND         | `u6`        | Transaction does not exist. |
| ERR-MAX-SIGNERS          | `u7`        | Maximum owners exceeded. |
| ERR-LIST-OVERFLOW        | `u8`        | List size exceeded. |
| ERR-NOT-PENDING          | `u9`        | Transaction is not pending. |
| ERR-ALREADY-OWNER        | `u10`       | Owner already exists. |
| ERR-NOT-OWNER            | `u11`       | User is not an owner. |
| ERR-OWNER-THRESHOLD      | `u12`       | Removing an owner violates the threshold rule. |
| ERR-EXPIRED              | `u13`       | Transaction expired. |
| ERR-INVALID-SIG-COUNT    | `u14`       | Invalid signature count. |
| ERR-TX-ACTIVE            | `u15`       | Active transactions prevent change. |

## Data Structures

### Variables
- **`required-signatures`** (`uint`): Number of signatures required to execute a transaction.
- **`total-owners`** (`uint`): Total number of owners.
- **`tx-nonce`** (`uint`): Counter for tracking transaction IDs.
- **`tx-expiration`** (`uint`): Expiration time for transactions (~24 hours in blocks).

### Maps
- **`owners`** (`principal → bool`): Stores owners of the wallet.
- **`transactions`** (`uint → {recipient, amount, status, signatures, signers}`): Stores transaction details.
- **`transaction-signers`** (`{tx-id, signer} → bool`): Tracks signers per transaction.

## Functions

### Initialization
#### `initialize (owners-list (list 20 principal), threshold uint) → (ok true | error)`
- Sets up the contract with an initial set of owners and a signature threshold.

### Transaction Management
#### `submit-transaction (recipient principal, amount uint) → (ok tx-id | error)`
- Creates a new transaction, requiring M signatures before execution.

#### `sign-transaction (tx-id uint) → (ok true | error)`
- Allows an owner to sign a pending transaction.

#### `execute-transaction (tx-id uint) → (ok true | error)`
- Executes a transaction if it has enough signatures.

#### `cancel-transaction (tx-id uint) → (ok true | error)`
- Cancels a pending transaction (can be done by any owner).

### Owner Management
#### `add-owner (new-owner principal) → (ok true | error)`
- Adds a new owner (requires multi-signature approval).

#### `remove-owner (owner-to-remove principal) → (ok true | error)`
- Removes an existing owner (ensures the required threshold is maintained).

### Configuration
#### `update-required-signatures (new-threshold uint) → (ok true | error)`
- Updates the number of required signatures (requires multi-signature approval).

### Read-Only Functions
#### `get-transaction (tx-id uint) → (option {recipient, amount, status, signatures, signers})`
- Retrieves details of a specific transaction.

#### `get-required-signatures () → (uint)`
- Returns the number of required signatures.

#### `get-total-owners () → (uint)`
- Returns the total number of owners.

#### `is-valid-owner (user principal) → (bool)`
- Checks if a given user is an owner.

## Security Considerations
- **Only owners can submit, sign, and execute transactions** to prevent unauthorized actions.
- **Transactions require M-of-N signatures** to execute, preventing a single point of failure.
- **Signature checks prevent duplicate signings** by the same owner.
- **Owners cannot be removed if it breaks the threshold requirement** to maintain security.

## Deployment & Usage
### Steps to Deploy
1. Deploy the contract to the Stacks blockchain.
2. Call `initialize` with a list of initial owners and a signature threshold.

### Example Usage
1. **Submit a transaction:**
   ```clarity
   (contract-call? .multi-sig-wallet submit-transaction tx-recipient tx-amount)
   ```
2. **Sign a transaction:**
   ```clarity
   (contract-call? .multi-sig-wallet sign-transaction tx-id)
   ```
3. **Execute a transaction (once signed):**
   ```clarity
   (contract-call? .multi-sig-wallet execute-transaction tx-id)
   ```
4. **Check transaction details:**
   ```clarity
   (contract-call? .multi-sig-wallet get-transaction tx-id)
   ```

## License
This project is open-source and available under the MIT License.

