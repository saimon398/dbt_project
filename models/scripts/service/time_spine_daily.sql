WITH days AS (
  {{
    dbt_utils.date_spine(
      datepart = 'day',
      start_date = "cast('2020-01-01' as date)",
      end_date = "cast('2030-01-01' as date)"
    )
  }}
)

SELECT cast(date_day AS date) AS date_day
FROM days
