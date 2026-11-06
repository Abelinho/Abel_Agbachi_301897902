-- Q1: List completed transactions and the accounts they affected.
-- Joins transaction, transaction_entry and account.
-- Shows completed deposits, withdrawals, transfers and reversals.

SELECT
    t.transaction_id,
    t.transaction_type,
    t.amount,
    a.account_number,
    te.direction,
    t.created_at
FROM public.transaction t
JOIN public.transaction_entry te
    ON te.transaction_id = t.transaction_id
JOIN public.account a
    ON a.account_id = te.account_id
WHERE t.status = 'COMPLETED'
ORDER BY t.created_at, t.transaction_id, a.account_number;

-- Q2: Find accounts that have never appeared in a transaction.
-- An account is returned only when no matching
-- transaction_entry record exists.

SELECT
    a.account_number,
    a.status
FROM public.account a
WHERE NOT EXISTS (
    SELECT 1
    FROM public.transaction_entry te
    WHERE te.account_id = a.account_id
)
ORDER BY a.account_number;

-- Q3: Count accounts for each customer.
-- LEFT JOIN keeps customers who might have zero accounts.

SELECT
    c.customer_number,
    c.full_name,
    COUNT(a.account_id) AS total_accounts
FROM public.customer c
LEFT JOIN public.account a
    ON a.customer_id = c.customer_id
GROUP BY
    c.customer_id,
    c.customer_number,
    c.full_name
ORDER BY c.customer_number;