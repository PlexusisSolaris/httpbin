FROM python:3.14.5-alpine AS builder

WORKDIR /app

COPY Pipfile Pipfile.lock ./

RUN pip install --no-cache-dir pipenv && pipenv install --deploy --system

FROM python:3.14.5-alpine

WORKDIR /app

COPY --from=builder /usr/local/lib/python3.14/site-packages /usr/local/lib/python3.14/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

COPY httpbin httpbin

RUN addgroup -g 1000 httpbin && adduser -u 1000 -G httpbin -D httpbin && chown -R httpbin:httpbin /app

USER httpbin

EXPOSE 8080

CMD ["gunicorn", "-b", "0.0.0.0:8080", "-k", "gevent", "httpbin:app"]
