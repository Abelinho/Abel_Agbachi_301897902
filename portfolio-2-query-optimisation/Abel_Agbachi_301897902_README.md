# Portfolio 2 Query Processing and Optimisation
##Queries and results

Query 1 listed completed transactions and the accounts affected by them. Using the sample data from Portfolio 1, it returned 4 rows: one completed deposit entry, one completed withdrawal entry, and two entries for the completed transfer.

Query 2 identified accounts with no related transaction entries using NOT EXISTS. It returned ACC2004, which was the only account that had not been used in any transaction entry.

Query 3 counted accounts per customer using a LEFT JOIN so customers with zero accounts would still be included. The results showed Alice Carter = 2 accounts, Brian Okafor = 1 account, and Chloe Reed = 1 account.

Index comparison

The optimisation test used the p2_benchmark.transaction_history table containing 100,000 synthetic rows. The query remained unchanged and filtered transactions between 2025-05-01 and 2025-05-31. A B-tree index named idx_transaction_history_transaction_date was added on transaction_date.

Measurement	Before index	After indexScan type	Sequential Scan (Seq Scan)	Bitmap Index Scan + Bitmap Heap Scan
Three execution times (ms)	6.027, 7.823, 5.771	0.835
Median time (ms)	6.027	0.835
Shared buffer hits, third run	834	50
Performance analysis

Before indexing, PostgreSQL used a sequential scan and examined all 100,000 rows, removing 96,900 rows during filtering. After the index was created, PostgreSQL used a Bitmap Index Scan and Bitmap Heap Scan on idx_transaction_history_transaction_date, reading only the rows needed for the date range. The measured execution time decreased from a median of 6.027 ms before indexing to 0.835 ms after indexing. These results were collected in a GitHub Codespaces environment and may vary on different hardware or under different workloads. An index can improve some read operations, but it also requires additional storage space and increases the work needed when inserting, updating or deleting indexed values.

Files
File	ContentsAbel_Agbachi_301897902_P2_Queries.sql	Portfolio 2 query processing examples and results.
Abel_Agbachi_301897902_P2_Optimisation.sql	Benchmark setup, index creation and execution plan testing.
screenshots/	Saved queries, execution plans and benchmark evidence.
Reference
PostgreSQL Documentation: Using EXPLAIN
PostgreSQL Documentation: Indexes