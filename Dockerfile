FROM python:3.12-slim AS builder

WORKDIR /app

COPY Pipfile .

RUN pip install --no-cache-dir pipenv && pipenv lock && pipenv install --deploy --system

FROM python:3.12-slim

WORKDIR /app

COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

COPY httpbin httpbin

RUN useradd -m httpbin -u 1000 && chown -R httpbin:httpbin /app

USER httpbin

EXPOSE 8080

CMD ["gunicorn", "-b", "0.0.0.0:8080", "-k", "gevent", "httpbin:app"]
