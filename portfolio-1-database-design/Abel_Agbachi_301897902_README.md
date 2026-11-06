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

## Design and implementation files
File	ContentsAbel_Agbachi_301897902_Design.md	Entities, attributes, keys and relationships.
Abel_Agbachi_301897902_ERDiagram.md	The four tables and their relationships.
Abel_Agbachi_301897902_P1_Normalisation.md	Example tables showing 1NF, 2NF and 3NF.
Abel_Agbachi_301897902_P1_Schema.sql	Table definitions, keys, foreign keys, checks and the reversal index.
Abel_Agbachi_301897902_P1_SampleData.sql	Fictional customers, accounts, transactions and transaction entries.
Abel_Agbachi_301897902_P1_ConstraintTests.sql	Invalid inserts and the final count query.
screenshots/	Saved commands and results.

## Implementation

The database runs on PostgreSQL in GitHub Codespaces. Its name is bank_fintech_portfolio. It contains customer, account, transaction and transaction_entry tables. Each table has a primary key, while foreign keys link accounts to customers, transaction entries to transactions and accounts, and reversals to the original transaction.

Unique constraints enforce customer numbers, customer emails and account numbers. CHECK constraints enforce valid account statuses, transaction types, transaction statuses, positive transaction amounts and transaction entry directions. A unique partial index ensures that a transaction can be referenced as a reversal only once. The schema and sample data were loaded first, and the invalid inserts were then tested separately.

## Test results

The constraint tests rejected records that violated required fields, unique constraints, foreign key constraints, CHECK constraints and the conditional uniqueness rule on reversed_transaction_id. Each invalid statement used otherwise valid values so that only the intended rule was tested.

The final counts remained unchanged after all failed inserts: 3 customers, 4 accounts, 6 transactions and 8 transaction entries. The failed inserts added no rows to the database.

Some business rules are not enforced by the table definitions alone. These include validating that a transaction date is not earlier than the account opening date, ensuring transfers use two different accounts, enforcing the required number of transaction entries per transaction type, preventing reversals of non-completed transactions, preventing a reversal from being reversed, and handling account locking or concurrency control. These rules require application or transaction logic and will need further testing in later portfolio work.