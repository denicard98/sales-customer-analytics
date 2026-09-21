/* ============================================================
   Sales & Customer Analytics — Validation Queries
   SQL Server / T-SQL
   Run against the SQL_Practice database (see database/schema_setup.sql)

   These queries independently reconcile results from
   analysis/business_questions.sql by aggregating the same data
   through a different grouping. They don't answer a business
   question on their own — they confirm that different
   breakdowns of the same underlying data agree with each other.
   ============================================================ */

USE SQL_Practice;
GO


/* ------------------------------------------------------------
   Grand total: total revenue across all completed orders.

   Used to reconcile Q4 (revenue by country), Q5 (revenue by
   category) and Q8 (revenue by Sales employee) in
   business_questions.sql — each of those result sets sums back
   to this same total, confirming the three breakdowns are
   consistent with each other.

   Expected result: 19103.00
   ------------------------------------------------------------ */
SELECT
    SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100)) AS total_completed_revenue
FROM Orders AS o
INNER JOIN OrderItems AS oi
    ON o.order_id = oi.order_id
WHERE o.status = 'Completed';

