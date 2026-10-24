# Bank/Fintech Platform ER Diagram

```mermaid
erDiagram
    direction LR

    customer ||--o{ account : "holds"
    transaction ||--o{ transaction_entry : "has"
    account ||--o{ transaction_entry : "appears in"
    transaction |o--o| transaction : "reverses"

    customer {
        BIGINT customer_id PK
        VARCHAR(30) customer_number UK
        VARCHAR(120) full_name
        VARCHAR(254) email UK
    }

    account {
        BIGINT account_id PK
        VARCHAR(30) account_number UK
        BIGINT customer_id FK
        TIMESTAMPTZ opened_at
        VARCHAR(10) status
    }

    transaction {
        BIGINT transaction_id PK
        VARCHAR(10) transaction_type
        NUMERIC(14,2) amount
        VARCHAR(12) status
        TIMESTAMPTZ created_at
        BIGINT reversed_transaction_id FK
    }

    transaction_entry {
        BIGINT entry_id PK
        BIGINT transaction_id FK
        BIGINT account_id FK
        VARCHAR(6) direction
    }
```

**Key and symbol meanings.** PK (primary key) is the field that identifies each row uniquely, such as `customer_id`. FK (foreign key) is a field that points to a row in another table, such as `account.customer_id` pointing to `customer.customer_id`. UK (unique) means no two rows share that value, such as `account_number`. In the relationship lines, `||` means exactly one, `|o` means zero or one, and `o{` means zero or many. Read left to right, `customer ||--o{ account` means one customer holds zero or many accounts, and each account belongs to exactly one customer. For example, customer C-1001 holds two accounts, A-5001 and A-5002, so the customer row stands on the "one" side and the two account rows stand on the "many" side.

`transaction |o--o| transaction` is the self-relationship for a reversal: a transaction reverses zero or one other transaction, and a reversal refers to exactly one original.

**Optional fields.** Only `transaction.reversed_transaction_id` is optional; it stays empty (NULL) for deposits, withdrawals and transfers, and is filled only on a reversal. Every other field in all four tables is required.

**Rules needing more than keys.** Rule 4 (a transfer uses two different accounts) is checked by the transfer operation, because no single column can compare two accounts. Rule 6 (`created_at >= opened_at`) crosses the transaction and account tables, so the operation validates it. Rule 7 needs transaction logic to reverse only a COMPLETED transaction and to refuse reversing a reversal. Rule 8 needs row locking so an account cannot start a conflicting transfer while another is in progress.