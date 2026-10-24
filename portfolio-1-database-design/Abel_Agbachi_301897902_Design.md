Bank/Fintech Platform Database Design
Entities
I chose four entities:

customer — a person holding one or more accounts.
account — one bank account belonging to a customer.
transaction — one money movement: a deposit, withdrawal, transfer or reversal.
transaction_entry — the link between a transaction and each account it touches.
I keep transaction and transaction_entry separate. A deposit touches one account, a transfer touches two. For example, a transfer of 5000 has two entries, a debit on the source and a credit on the destination. One structure records both, and a statement lists entries per account.

Attributes and keys
customer: customer_id BIGINT PK; customer_number VARCHAR(30) unique; full_name VARCHAR(120); email VARCHAR(254) unique. All required.

account: account_id BIGINT PK; account_number VARCHAR(30) unique; customer_id BIGINT FK → customer.customer_id; opened_at TIMESTAMPTZ; status VARCHAR(10). All required.

transaction: transaction_id BIGINT PK; transaction_type VARCHAR(10); amount NUMERIC(14,2); status VARCHAR(12); created_at TIMESTAMPTZ; reversed_transaction_id BIGINT FK → transaction.transaction_id. All required except reversed_transaction_id.

transaction_entry: entry_id BIGINT PK; transaction_id BIGINT FK → transaction.transaction_id; account_id BIGINT FK → account.account_id; direction VARCHAR(6). All required.

BIGINT holds whole numbers; VARCHAR(n) holds text up to n characters; NUMERIC(14,2) holds money with two decimals; TIMESTAMPTZ holds a date and time with time zone. Balance is not stored: it equals the sum of an account's entries and is calculated when read.

Relationships
customer → account: one to many. A customer has zero or more accounts; each account belongs to exactly one customer.

transaction → transaction_entry: one to many. A transaction has one or two entries; each entry belongs to exactly one transaction.

account → transaction_entry: one to many. An account has zero or more entries; each entry belongs to exactly one account.

transaction → transaction: optional one to one. A reversal references the original transaction. The linking table transaction_entry resolves the many-to-many between transactions and accounts.

Business rules and constraints
customer_number and email are each UNIQUE; all customer columns are NOT NULL.
account_number is UNIQUE; customer_id FK NOT NULL gives the one-customer link, while one customer can own many accounts.
transaction_entry.account_id FK NOT NULL ensures each entry names an existing account; the operation inserts one or two entries per transaction.
CHECK (amount > 0) on transaction. Two different accounts cannot be enforced by one column, so the transfer operation compares the entry accounts and rejects equal ones.
transaction_type and direction are limited by CHECK; the operation writes one entry for a deposit or withdrawal and two for a transfer.
created_at >= opened_at crosses tables, so no key or single-column check enforces it; the operation validates it.
reversed_transaction_id is a self-FK; status CHECK marks the original REVERSED. A key cannot restrict this, so the operation allows only a COMPLETED transaction to be reversed and refuses to reverse a reversal.
A key cannot lock rows, so the operation locks the account until its in-progress transaction completes before starting a conflicting transfer.
Design assumptions
One currency, so amount is a plain number without a currency column.
Balance is derived, not stored, to avoid a value drifting from its entries.
Account status (ACTIVE/CLOSED) is kept; authentication is out of scope, so there is no user entity.