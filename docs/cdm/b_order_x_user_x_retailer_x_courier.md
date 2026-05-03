{% docs b_order_x_user_x_retailer_x_courier %}

#### Описание модели
Таблица-bridge слоя Business Vault. Объединяет ключи четырёх сущностей вокруг одного заказа:
- "Заказ" (`order_id`);
- "Пользователь" (`user_id`);
- "Ритейлер" (`retailer_id`);
- "Курьер" (`courier_id`).

Назначение — упростить построение витрин и BI-отчётов: вместо последовательных join'ов по нескольким линкам потребитель использует один заранее «склеенный» bridge с готовыми ключами.

#### Источник
Все источники — линки слоя Raw Vault:
- `ref('l_user_x_order')` — задаёт пары "Пользователь — Заказ" (драйверная таблица).
- `ref('l_retailer_x_order')` — добавляет ключ ритейлера через `LEFT JOIN` по `order_id`.
- `ref('l_courier_x_order')` — добавляет ключ курьера через `LEFT JOIN` по `order_id`.

#### Схема
Модель материализуется в схеме `cdm`.

#### Материализация
`incremental`. При обычном запуске вставляются только записи с новыми `order_id` (фильтр `a.order_id NOT IN (SELECT order_id FROM this)`). Полная пересборка возможна через `--full-refresh`.

#### Особенности
- `bridge_link_id` — суррогатный ключ записи bridge: `md5` от конкатенации `order_id`, `user_id`, `retailer_id`, `courier_id` с `coalesce(..., '')` для устойчивости к `NULL`.
- Внешние объединения по `order_id` означают, что `retailer_id` и/или `courier_id` могут быть `NULL`, если соответствующая связь ещё не появилась в Raw Vault.
- `mt_src_id` — фиксированное значение `BUSINESS VAULT`.
- Теги модели: `business_vault`, `bridge`.
- Тесты: `unique` на `bridge_link_id`, `relationships` на `h_order.order_id`, `h_user.user_id`, `h_retailer.retailer_id` (см. `models/schemas/cdm/b_order_x_user_x_retailer_x_courier.yml`).
- Инкрементальный фильтр устроен по `order_id`, поэтому повторные изменения связей в рамках уже существующего заказа в bridge не подтягиваются — для полного пересчёта используется `--full-refresh`.

{% enddocs %}
