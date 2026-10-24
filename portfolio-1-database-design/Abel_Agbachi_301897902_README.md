# Portfolio 1 Database Design and Modelling

## Case study
A bank/fintech platform holds customer records, bank accounts and the money movements between them. Customers hold and move funds, while staff and auditors oversee transfers, deposits and withdrawals. Every transaction is recorded so balances can be traced and audited.

## Users
Customers open accounts, deposit and withdraw funds, and transfer money to other accounts. Tellers record counter deposits and withdrawals on behalf of customers. Operations staff investigate and reverse failed transfers. Auditors review transaction logs and balances without changing them.

## Main operations
Register a customer and open an account; record a deposit; record a withdrawal; transfer funds between two accounts; reverse a failed transaction; view an account statement and balance; review transaction logs for audit.

## Business rules
1. Each customer has a unique customer number and a unique email address.
2. Each account has a unique account number and belongs to one customer; a customer may hold several accounts.
3. Each transaction affects one or two existing accounts, identified by account number.
4. A transfer must involve two different accounts, and its amount must be greater than zero.
5. A deposit or withdrawal involves a single account; a transfer involves a source and a destination account.
6. The transaction date must not be earlier than the account opening date.
7. A reversal applies only to a completed transaction and cannot itself be reversed; the original is marked reversed, not deleted.
8. An account with an in-progress transaction cannot start a conflicting transfer until that transaction completes.

## Scope
This design covers one fictional retail bank: customer records, accounts, deposits, withdrawals, transfers and transaction logs. It excludes loans, credit cards, interest and fees, currency exchange, authentication and regulatory reporting.