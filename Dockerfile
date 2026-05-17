# собираем базовый образ
FROM python:3.11-slim

# устанавливаем необходимые системные зависимости (git и ca-certificates для работы с git-репозиториями)
RUN apt-get update \
    && apt-get install -y --no-install-recommends git ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# устанавливаем uv
RUN pip install --no-cache-dir uv

# устанавливаем рабочую директорию
WORKDIR /dbt

# копируем файлы с зависимостями и устанавливаем их
COPY pyproject.toml uv.lock ./
RUN uv sync --locked --no-dev

# копируем файлы для установки dbt-зависимостей
COPY packages.yml package-lock.yml dbt_project.yml profiles.example.yml ./
RUN cp profiles.example.yml profiles.yml \
    && uv run dbt deps

# копируем весь проект, кроме того, что указано в .dockerignore
COPY . .

# устанавливаем DBT в PATH, чтобы бинарник был доступен напрямую
ENV PATH="/dbt/.venv/bin:$PATH"

# добавляем нового пользователя и переключаемся на него для безопасности
RUN useradd -m dbtuser \
    && chown -R dbtuser:dbtuser /dbt
USER dbtuser

ENTRYPOINT ["dbt"]
CMD ["--help"]
