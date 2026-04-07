### Тестовый проект для понимания работы DBT

#### Структура проекта
- models:
    - sources: описание источников данных (yml-файл)
    - schemas: описание моделей (yml-файлы)
    - scripts: sql-запросы для сборки моделей
- tests
    - generic: тесты с простой логикой, которые можно применить к любым моделям
    - singular: тесты с нетривиальной логикой для определенных моделей


#### Полезные команды

- `dbt parse`
- `dbt ls`
- `dbt run --select <model_name>`
- `dbt test --select source:ods test_type:singular`
- `dbt docs generate`
- `dbt docs serve`
- `dbt deps --add-package`
