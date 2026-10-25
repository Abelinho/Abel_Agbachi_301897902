# Bank/Fintech Platform Normalisation

Normalisation separates information into related tables so the same detail is not repeated and cannot drift out of step. The same three fictional money movements are used below. Only the fields needed to explain the changes are shown; the full design keeps the other fields from the design document.

Dates are shortened for readability. `created_at` represents the full date and time. Names and emails are fictional. Balances are not shown because the design calculates them from entries.

The three movements are:
- A deposit of 200 into account A-5001.
- A transfer of 5000 from A-5001 to A-5002.
- A reversal of that transfer.

## Starting movement list

| transaction_id | transaction_type | amount | customer_number | full_name | email | account_number | direction | affected accounts |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | deposit | 200 | C-1001 | Ada James | ada@example.com | A-5001 | credit | A-5001: customer C-1001, Ada James, credit 200 |
| 2 | transfer | 5000 | C-1001 | Ada James | ada@example.com | A-5001 | debit | A-5001: customer C-1001, debit 5000; A-5002: customer C-1002, Ben Cole, credit 5000 |
| 3 | reversal | 5000 | C-1001 | Ada James | ada@example.com | A-5001 | credit | A-5001: customer C-1001, credit 5000 (reverses transaction 2) |

The transfer row packs two accounts into one cell. Reading one account's side, or recording a return, is awkward. Ada's email repeats on every row.

## 1NF: One value per cell

Each account side of a movement gets its own row. The repeated list is removed.

| transaction_id | transaction_type | amount | customer_id | customer_number | full_name | email | account_id | account_number | direction |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | deposit | 200 | 1 | C-1001 | Ada James | ada@example.com | 11 | A-5001 | credit |
| 2 | transfer | 5000 | 1 | C-1001 | Ada James | ada@example.com | 11 | A-5001 | debit |
| 2 | transfer | 5000 | 2 | C-1002 | Ben Cole | ben@example.com | 12 | A-5002 | credit |
| 3 | reversal | 5000 | 1 | C-1001 | Ada James | ada@example.com | 11 | A-5001 | credit |

For this example, the key is **(transaction_id, account_id)**: the transaction plus the account it touches. `transaction_id` alone is not enough, because the transfer (2) appears twice. Both values together identify one entry, assuming a transaction touches a given account at most once per direction.

The rows are in 1NF, but the customer email repeats, and the amount repeats for both sides of the transfer.

## 2NF: Details depend on the whole key

2NF includes 1NF. A non-key field must not depend on only part of a combined key.

Here, **customer_id, customer_number, full_name and email depend on customer_id, not on the whole (transaction_id, account_id) key**. They describe the customer, not one side of a movement. In the agreed design the customer lives in its own table linked by `account_id`, so these fields move out.

### customer (selected fields)

Key: **customer_id**.

| customer_id | customer_number | full_name | email |
| --- | --- | --- | --- |
| 1 | C-1001 | Ada James | ada@example.com |
| 2 | C-1002 | Ben Cole | ben@example.com |

### Movement entry details

Key: **(transaction_id, account_id)**.

| transaction_id | transaction_type | amount | account_number | direction |
| --- | --- | --- | --- | --- |
| 1 | deposit | 200 | A-5001 | credit |
| 2 | transfer | 5000 | A-5001 | debit |
| 2 | transfer | 5000 | A-5002 | credit |
| 3 | reversal | 5000 | A-5001 | credit |

The email no longer repeats per entry. The amount still repeats across the two transfer sides, and `account_number` still sits beside the entry.

## 3NF: Keep details with the thing they describe

3NF includes 2NF. Non-key fields must not depend on another non-key field. Three links explain the next split:

- **transaction_id determines transaction_type, amount, status and created_at**: these describe the movement, not one account side.
- **account_id determines account_number and customer_id**: these describe the account, not the entry.
- **customer_id determines full_name and email** (already handled above).

### transaction (selected fields)

Key: **transaction_id**. `reversed_transaction_id` points back to transaction for a reversal.

| transaction_id | transaction_type | amount | status | reversed_transaction_id |
| --- | --- | --- | --- | --- |
| 1 | deposit | 200 | completed | NULL |
| 2 | transfer | 5000 | completed | NULL |
| 3 | reversal | 5000 | completed | 2 |

### account (selected fields)

Key: **account_id**. customer_id is a foreign key to customer.

| account_id | account_number | customer_id |
| --- | --- | --- |
| 11 | A-5001 | 1 |
| 12 | A-5002 | 2 |

### transaction_entry

The final design gives this table its own **entry_id** as primary key rather than relying on the combined key. transaction_id and account_id are foreign keys.

| entry_id | transaction_id | account_id | direction |
| --- | --- | --- | --- |
| 1 | 1 | 11 | credit |
| 2 | 2 | 11 | debit |
| 3 | 2 | 12 | credit |
| 4 | 3 | 11 | credit |

Now Ada's email is stored once in customer, the amount is stored once in transaction, and the account number is stored once in account. The IDs preserve the links, so a movement and all the accounts it touches can still be brought together.

These are the four tables in the ER diagram. The complete schema also includes `opened_at`, `status` and `created_at`. Balances, unique values, the amount check, the two-different-accounts rule and the reversal rule remain necessary; normalisation does not enforce those rules by itself. The combined (transaction_id, account_id) key was replaced by the generated entry_id: an ID alone does not make a table 3NF, it only gives each entry a stable reference.