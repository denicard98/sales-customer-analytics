# Sales & Customer Analytics

A hands-on SQL portfolio project built while learning SQL Server / T-SQL. It uses a small, self-generated practice dataset (synthetic sales data, modeled on a typical e-commerce schema) to answer realistic business questions a Sales or Analytics team might ask.

This is a learning project, not professional work experience — the goal is to demonstrate SQL fundamentals (joins, aggregation, filtering, set operators) applied to a business scenario, with every query kept simple enough to explain step by step.

## Business Problem

A retail company sells Electronics, Accessories and Furniture products online to customers across six countries. Management wants to understand:

- Which customers and markets are actually generating revenue
- Where customer activity is concentrated or missing (inactive/Premium customers)
- Which product categories generate the most revenue and sales volume

The queries in this project answer those questions directly from the transactional data.

## Dataset

Five related tables, created and populated by [`database/schema_setup.sql`](database/schema_setup.sql):

| Table | Rows | Description |
|---|---|---|
| `Customers` | 18 | Customer profile, country/city, signup date, segment (`Regular`/`Premium`), loyalty score |
| `Products` | 10 | Product catalog: name, category, unit price, cost price, supplier country |
| `Employees` | 8 | Sales/Finance/IT/Marketing staff, with a self-referencing `manager_id` |
| `Orders` | 25 | One row per order: customer, employee, date, status (`Completed`/`Pending`/`Cancelled`), payment method |
| `OrderItems` | 41 | Line items per order: product, quantity, unit price, discount % |

```
Customers ──< Orders ──< OrderItems >── Products
                │
             Employees ──(self FK: manager_id)
```

## Business Questions

1. Which customers are generating actual commercial activity (completed orders)?
2. Which customers placed the most completed orders (≥2)?
3. Which Premium customers have never placed an order?
4. Which countries generate the most revenue from completed orders?
5. Which product categories perform best (revenue and units sold)?
6. How many registered customers, by country, have never placed an order?
7. Which customers bought from both the Electronics and Accessories categories?
8. How does completed-order performance vary across Sales employees?

Full queries: [`analysis/business_questions.sql`](analysis/business_questions.sql)

## Analytical Approach

- Only `'Completed'` orders are counted as revenue/activity unless the question is specifically about inactive customers.
- Revenue is calculated as `quantity * unit_price * (1 - discount_percent / 100)` at the order-item level, then aggregated.
- **Join choice reflects the business question, not habit**: `INNER JOIN` is used wherever the analysis requires a matched record (e.g. an order must have a customer); `LEFT JOIN` is used only where unmatched records *are* the answer — e.g. Premium customers with no matching order (Q3), or customers with no matching order at all (Q6). These are classic anti-join patterns (`WHERE <right side> IS NULL`).
- Q3 includes a second, independent query that validates the main result using a different SQL technique (`EXCEPT`) — a genuine cross-check, since it answers the same question a different way.
- Q4 includes a second query that adds distinct completed-order counts per country. This is **additional analysis**, not validation — it enriches the result with another metric rather than confirming it independently.
- Q7 uses `INTERSECT` to find customers present in *both* category result sets, instead of a more complex join/subquery.
- [`analysis/validation_queries.sql`](analysis/validation_queries.sql) contains a genuine reconciliation check: a single grand-total revenue query that Q4 (by country), Q5 (by category) and Q8 (by Sales employee) should each sum back to. This is a stronger check than "the query ran without error" — it confirms that three independently grouped aggregations of the same data agree with each other.

## SQL Skills Demonstrated

- Multi-table `INNER JOIN` / `LEFT JOIN`, chosen deliberately based on what the question needs
- Anti-join pattern (`LEFT JOIN ... WHERE right.key IS NULL`) to find non-matching records
- Aggregation: `SUM`, `COUNT`, `COUNT(DISTINCT ...)`
- Grouping and filtering aggregates with `GROUP BY` / `HAVING`
- Derived/calculated columns (discount-adjusted revenue)
- Set operators `EXCEPT` and `INTERSECT` for validation and multi-condition matching
- Result validation by cross-checking a query with a second, differently-built query
- Reconciling independently grouped aggregates back to a single grand total

## How to Run

1. Run [`database/schema_setup.sql`](database/schema_setup.sql) in SSMS or `sqlcmd` — creates the `SQL_Practice` database, tables and sample data.
2. Run [`analysis/business_questions.sql`](analysis/business_questions.sql) — each of the 8 business questions is a standalone, labeled query block.
3. Optionally run [`analysis/validation_queries.sql`](analysis/validation_queries.sql) — reconciles Q4, Q5 and Q8 against a single grand total.

## Findings

**Q1 — Completed order activity.** 19 of the 25 orders (76%) reached `Completed` status, spanning January to August 2025 across all 6 countries, with `Card` as the most frequent payment method in the list.

**Q2 — Repeat customers.** Only 4 customers have 2 or more completed orders: Miguel (Portugal, 3), Laura (Germany, 3), Carlos (Spain, 2) and Ana (Portugal, 2). Repeat activity is concentrated in a small group.

**Q3 — Premium customers with no orders.** Zero Premium customers have never ordered — every Premium-segment customer in this dataset has at least one order on record. Both the main query and the `EXCEPT`-based validation query agree (empty result set). Based on this data, there are no potential activation targets within the Premium segment.

**Q4 — Revenue by country.**

| Country | Total Revenue | Orders Contributing |
|---|---|---|
| Portugal | 6250.00 | 7 |
| Germany | 5183.00 | 4 |
| Spain | 3190.00 | 3 |
| France | 2185.00 | 2 |
| UK | 1930.00 | 2 |
| Italy | 365.00 | 1 |

Portugal generates the highest completed-order revenue (6250.00 across 7 orders), followed by Germany (5183.00 across 4 orders). Together, these two markets account for the majority of completed-order revenue in the dataset.

**Q5 — Category performance.**

| Category | Total Revenue | Units Sold |
|---|---|---|
| Electronics | 16003.00 | 21 |
| Accessories | 1700.00 | 20 |
| Furniture | 1400.00 | 4 |

Electronics generates about 84% of total completed-order revenue while selling 21 units, compared with 20 Accessories units. This indicates a substantially higher revenue contribution per unit from Electronics in this dataset. Furniture sells the fewest units (4) but still outperforms Accessories on revenue per unit sold.

**Q6 — Inactive registered customers by country.** Only Germany (2) and Portugal (1) have customers who never placed an order; the other four countries have none. Inactivity is limited and concentrated, not spread across the customer base.

**Q7 — Cross-category buyers (Electronics + Accessories).** 6 customers purchased from both categories in completed orders: Ana, Miguel, Sofia (Portugal), Laura (Germany), Carlos (Spain) and Emma (UK). Four of these customers — Ana, Miguel, Laura and Carlos — also appear among the repeat customers identified in Q2.

**Q8 — Completed-order performance across Sales employees.** (Only Sales employees with at least one completed order appear, due to the `INNER JOIN`.)

| Employee | Orders | Revenue |
|---|---|---|
| Julia (203) | 8 | 8738.00 |
| Pedro (202) | 7 | 6250.00 |
| Sarah (201) | 4 | 4115.00 |

Julia generated the highest completed-order revenue (8738.00) and the highest number of completed orders (8), followed by Pedro and Sarah. This comparison is limited to Sales employees with at least one completed order.

**Cross-check.** The grand-total query in [`analysis/validation_queries.sql`](analysis/validation_queries.sql) returns 19103.00 in total completed-order revenue — matching the sum of Q4 (by country), Q5 (by category) and Q8 (by Sales employee) exactly, confirming the three breakdowns are consistent with each other.

## Repository Structure

```
sales-customer-analytics/
├── README.md
├── database/
│   └── schema_setup.sql        -- creates database, tables and sample data
└── analysis/
    ├── business_questions.sql  -- the 8 business questions (+ 1 validation, 1 additional-analysis query)
    └── validation_queries.sql  -- grand-total reconciliation check for Q4, Q5, Q8
```
