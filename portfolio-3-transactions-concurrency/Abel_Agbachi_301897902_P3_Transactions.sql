-- Starting data for the exercise.

SELECT
    account_number,
    status
FROM public.account
WHERE account_number IN ('ACC2003', 'ACC2004')
ORDER BY account_number;

BEGIN;

-- Close ACC2003 only if it is currently ACTIVE.
UPDATE public.account
SET status = 'CLOSED'
WHERE account_number = 'ACC2003'
  AND status = 'ACTIVE';

COMMIT;

SELECT
    account_number,
    status
FROM public.account
WHERE account_number = 'ACC2003';

BEGIN;

-- Valid change inside the transaction.
UPDATE public.account
SET status = 'ACTIVE'
WHERE account_number = 'ACC2004';

-- Deliberate constraint violation.
-- 'OPEN' is not allowed by chk_account_status.
INSERT INTO public.account (
    account_number,
    customer_id,
    opened_at,
    status
)
VALUES (
    'ACC9999',
    1,
    TIMESTAMPTZ '2026-04-01 09:00:00+00',
    'OPEN'
);

ROLLBACK;

--verification after roll back
SELECT
    account_number,
    status
FROM public.account
WHERE account_number IN ('ACC2003', 'ACC2004')
ORDER BY account_number;

--check that invalid account was not created
SELECT
    account_number,
    status
FROM public.account
WHERE account_number = 'ACC9999';


