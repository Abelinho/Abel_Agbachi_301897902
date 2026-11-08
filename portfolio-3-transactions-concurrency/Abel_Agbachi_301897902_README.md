# Portfolio 3 Transactions and Concurrency
## Commit and rollback

A transaction was used to change account ACC2003 from ACTIVE to CLOSED and the change was saved with COMMIT. A repeat check confirmed that the account remained closed. In a second transaction, a valid update was made to ACC2004, but an attempt to insert a new account with an invalid status value violated the chk_account_status constraint. The error caused the transaction to be rolled back, so the change to ACC2004 was not saved while the earlier committed change remained.

## Isolation and concurrency control

Two PostgreSQL sessions were run using the READ COMMITTED isolation level. Session A inserted a new account (ACC5001) and left the transaction open. Session B could not see the uncommitted row and its check returned zero matching accounts. When Session B attempted to insert the same account number, it waited for Session A to finish. After Session A committed, PostgreSQL enforced the unique constraint on account_number and rejected Session B's insert with a duplicate-key error. Session B then rolled back, and the final verification query showed that only one ACC5001 record existed.

## Conclusion

The exercises demonstrated that COMMIT permanently saves successful changes, while ROLLBACK removes changes made within an uncommitted transaction. The READ COMMITTED isolation level prevented one session from viewing another session's uncommitted data. The unique constraint on account_number protected data integrity during concurrent activity. However, isolation levels alone do not enforce business rules; constraints and application logic are still required to prevent conflicting operations.

## Files
Abel_Agbachi_301897902_P3_Transactions.sql
screenshots/
## References
PostgreSQL Documentation: Transactions
PostgreSQL Documentation: Transaction Isolation
PostgreSQL Documentation: Constraints