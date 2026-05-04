---
name: make-model-config
description: Creates *.md and *.yaml files for specific DBT-model. Triggers: "создай конфиг для модели", "сделай конфиг для модели", "опиши эту модель", "законфигурируй эту модель".
argument-hint: [model_name]
arguments: [model_name]
---

## Алгоритм действий

1. Прочитать SQL-файл модели $model_name, чтобы понять её колонки и логику.
2. Посмотреть существующие YAML/MD-файлы аналогичного типа модели в той же директории и **сверить** с ними:
   - набор тегов (`tags`),
   - набор служебных колонок (`mt_load_dttm`, ключи и т.п.),
   - стиль формулировок в `description` колонок,
   - наличие и состав `data_tests`.
3. Определить колонки и типы данных:
   - извлечь список колонок из финального `SELECT` модели,
   - типы взять из исходных таблиц / `ref()`-моделей; если тип неочевиден — уточнить у пользователя или использовать `mcp__dbt__generate_model_yaml` как стартовую заготовку.
4. Уточнить у пользователя материализацию, если она не указана в `config()` модели или в `dbt_project.yml` (по умолчанию — `table`).
5. Создать YAML-файл для $model_name.
6. Создать MD-файл для $model_name. **Вызвать скилл `create-doc`** — он отвечает за все правила и шаблоны MD.

---

## Правила размещения файлов

YAML-файлы располагаются в `models/schemas/`, MD-файлы — в `docs/`. Внутри каждой из этих директорий структура папок повторяет расположение SQL-модели **относительно `models/scripts/`**.

Пример: модель `h_user.sql` лежит в `models/scripts/cdm/`
- YAML → `models/schemas/cdm/h_user.yml`
- MD → `docs/cdm/h_user.md`

Имена файлов должны совпадать с именем SQL-модели.

---

## Пример структуры YAML-файла (на примере hub)

```yaml
version: 2

models:
  - name: h_user
    description: "{{ doc('h_user') }}"
    config:
      materialized: table        # задаётся пользователем, по умолчанию table
      on_schema_change: fail
      tags: ['hub']              # теги указываются внутри config
      contract:
        enforced: true
    columns:
      - name: h_user_pk
        description: Суррогатный ключ пользователя
        data_type: varchar
        data_tests:
          - unique
          - not_null
      - name: user_src_id
        description: Бизнес-ключ пользователя из источника
        data_type: varchar
        data_tests:
          - not_null
      - name: mt_load_dttm
        description: Дата загрузки
        data_type: timestamptz
```

Ключевые моменты:
- `version: 2` — обязателен на верхнем уровне.
- `description` использует синтаксис `{{ doc('имя_модели') }}` — ссылка на MD-файл.
- `tags` располагается внутри `config`, не на уровне модели.
- `on_schema_change: fail` — сборка падает при дрейфе колонок относительно YAML, чтобы расхождения ловились на этапе CI, а не в проде.
- `contract.enforced: true` — фиксирует схему модели (имена и типы колонок) и не даёт собрать модель, если SQL расходится с YAML.
- `data_tests` — указываются на уровне колонок. Минимум: `unique` + `not_null` для PK, `not_null` для бизнес-ключей и FK, `relationships` для FK-связей.

---

## Шаблоны по типам моделей

Ниже — мини-шаблоны для блоков `tags`, `columns`, `data_tests`. Шапка (`version`, `description`, `config.materialized`, `on_schema_change`, `contract`) одинакова для всех типов.

### Hub
```yaml
config:
  tags: ['hub']
columns:
  - name: h_<entity>_pk
    description: Суррогатный ключ сущности (хеш бизнес-ключа)
    data_type: varchar
    data_tests: [unique, not_null]
  - name: <entity>_src_id
    description: Бизнес-ключ сущности из источника
    data_type: varchar
    data_tests: [not_null]
  - name: mt_load_dttm
    description: Дата и время загрузки записи в хаб
    data_type: timestamptz
```

### Link
```yaml
config:
  tags: ['link']
columns:
  - name: l_<a>_x_<b>_pk
    description: Суррогатный ключ связи (хеш от ключей связанных хабов)
    data_type: varchar
    data_tests: [unique, not_null]
  - name: h_<a>_pk
    description: FK на хаб <a>
    data_type: varchar
    data_tests:
      - not_null
      - relationships: { to: ref('h_<a>'), field: h_<a>_pk }
  - name: h_<b>_pk
    description: FK на хаб <b>
    data_type: varchar
    data_tests:
      - not_null
      - relationships: { to: ref('h_<b>'), field: h_<b>_pk }
  - name: mt_load_dttm
    description: Дата и время загрузки связи
    data_type: timestamptz
```

### Satellite
```yaml
config:
  tags: ['satellite']
columns:
  - name: h_<entity>_pk
    description: FK на хаб сущности
    data_type: varchar
    data_tests:
      - not_null
      - relationships: { to: ref('h_<entity>'), field: h_<entity>_pk }
  - name: mt_load_dttm
    description: Дата и время загрузки версии записи
    data_type: timestamptz
  - name: mt_valid_from_dttm
    description: Начало периода действия версии атрибутов (SCD)
    data_type: timestamptz
  - name: mt_valid_to_dttm
    description: Конец периода действия версии атрибутов (SCD)
    data_type: timestamptz
  # ...описательные атрибуты сущности с описаниями и типами
```

### Mart / BI
```yaml
config:
  tags: ['mart', 'bi']
columns:
  - name: <dimension_key>
    description: Ключ измерения витрины
    data_type: varchar
    data_tests: [not_null]
  - name: <metric>
    description: Бизнес-метрика витрины (что считаем и в каких единицах)
    data_type: numeric
```
