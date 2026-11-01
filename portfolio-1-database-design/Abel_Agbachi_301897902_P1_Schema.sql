BEGIN;

-- customer: one person holding zero or more accounts
CREATE TABLE public.customer (
    customer_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_number VARCHAR(30) NOT NULL UNIQUE,
    full_name VARCHAR(120) NOT NULL,
    email VARCHAR(254) NOT NULL UNIQUE
);

-- account: one bank account belonging to one customer
CREATE TABLE public.account (
    account_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    account_number VARCHAR(30) NOT NULL UNIQUE,
    customer_id BIGINT NOT NULL,
    opened_at TIMESTAMPTZ NOT NULL,
    status VARCHAR(10) NOT NULL,
    CONSTRAINT fk_account_customer
        FOREIGN KEY (customer_id)
        REFERENCES public.customer (customer_id),
    CONSTRAINT chk_account_status
        CHECK (status IN ('ACTIVE', 'CLOSED'))
);

-- transaction: one business transaction
CREATE TABLE public.transaction (
    transaction_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    transaction_type VARCHAR(10) NOT NULL,
    amount NUMERIC(14,2) NOT NULL,
    status VARCHAR(12) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    reversed_transaction_id BIGINT NULL,
    CONSTRAINT fk_transaction_reversal
        FOREIGN KEY (reversed_transaction_id)
        REFERENCES public.transaction (transaction_id),
    CONSTRAINT chk_transaction_amount
        CHECK (amount > 0),
    CONSTRAINT chk_transaction_type
        CHECK (transaction_type IN ('DEPOSIT', 'WITHDRAWAL', 'TRANSFER', 'REVERSAL')),
    CONSTRAINT chk_transaction_status
        CHECK (status IN ('PENDING', 'COMPLETED', 'REVERSED', 'FAILED'))
);

-- transaction_entry: links transactions to affected accounts
CREATE TABLE public.transaction_entry (
    entry_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    transaction_id BIGINT NOT NULL,
    account_id BIGINT NOT NULL,
    direction VARCHAR(6) NOT NULL,
    CONSTRAINT fk_entry_transaction
        FOREIGN KEY (transaction_id)
        REFERENCES public.transaction (transaction_id),
    CONSTRAINT fk_entry_account
        FOREIGN KEY (account_id)
        REFERENCES public.account (account_id),
    CONSTRAINT chk_entry_direction
        CHECK (direction IN ('DEBIT', 'CREDIT'))
);

-- A reversal can reference only one original transaction
CREATE UNIQUE INDEX ux_transaction_reversed_transaction_id
    ON public.transaction (reversed_transaction_id)
    WHERE reversed_transaction_id IS NOT NULL;

-- Rules requiring transaction logic are not enforced here:
-- created_at >= opened_at (cross-table validation).
-- Transfers must use two different accounts.
-- Deposits/withdrawals require one entry; transfers require two entries.
-- Only COMPLETED transactions may be reversed.
-- A reversal cannot itself be reversed.
-- Account locking/concurrency control must be handled by application logic.

COMMIT;