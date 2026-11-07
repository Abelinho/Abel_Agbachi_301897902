-- Create a separate schema for Portfolio 2 benchmarking.
CREATE SCHEMA IF NOT EXISTS p2_benchmark;

-- Synthetic transaction history used only for benchmarking.
CREATE TABLE p2_benchmark.transaction_history (
    history_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    account_id BIGINT NOT NULL,
    transaction_date DATE NOT NULL,
    amount NUMERIC(14,2) NOT NULL,
    transaction_type VARCHAR(10) NOT NULL,
    CONSTRAINT fk_history_account
        FOREIGN KEY (account_id)
        REFERENCES public.account (account_id)
);

INSERT INTO p2_benchmark.transaction_history (
    account_id,
    transaction_date,
    amount,
    transaction_type
)
SELECT
    a.account_id,
    DATE '2024-01-01' + ((g.n - 1) % 1000),
    ROUND((10 + ((g.n * 17) % 5000))::numeric, 2),
    CASE (g.n % 4)
        WHEN 0 THEN 'DEPOSIT'
        WHEN 1 THEN 'WITHDRAWAL'
        WHEN 2 THEN 'TRANSFER'
        ELSE 'REVERSAL'
    END
FROM generate_series(1, 25000) AS g(n)
CROSS JOIN public.account a;

ANALYZE p2_benchmark.transaction_history;

SELECT COUNT(*) AS total_rows
FROM p2_benchmark.transaction_history;

SELECT
    history_id,
    account_id,
    transaction_date,
    amount,
    transaction_type
FROM p2_benchmark.transaction_history
WHERE transaction_date
      BETWEEN DATE '2025-05-01'
          AND DATE '2025-05-31'
ORDER BY transaction_date;

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    history_id,
    account_id,
    transaction_date,
    amount,
    transaction_type
FROM p2_benchmark.transaction_history
WHERE transaction_date
      BETWEEN DATE '2025-05-01'
          AND DATE '2025-05-31'
ORDER BY transaction_date;

CREATE INDEX idx_transaction_history_transaction_date
ON p2_benchmark.transaction_history (transaction_date);

ANALYZE p2_benchmark.transaction_history;

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    history_id,
    account_id,
    transaction_date,
    amount,
    transaction_type
FROM p2_benchmark.transaction_history
WHERE transaction_date
      BETWEEN DATE '2025-05-01'
          AND DATE '2025-05-31'
ORDER BY transaction_date;