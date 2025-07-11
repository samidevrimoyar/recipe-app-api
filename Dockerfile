FROM python:3.12-alpine
LABEL maintainer="superisi.net"

ENV PYTHONUNBUFFERED=1

# Gerekli sistem bağımlılıkları
RUN apk update && \
    apk add --no-cache \
    postgresql-client \
    jpeg-dev \
    zlib-dev \
    libpq && \
    apk add --no-cache --virtual .tmp-build-deps \
    build-base \
    postgresql-dev \
    musl-dev \
    zlib-dev \
    linux-headers

# Sanal ortam ve bağımlılıklar
RUN python -m venv /py
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
RUN /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ "$DEV" = "true" ]; then /py/bin/pip install -r /tmp/requirements.dev.txt; fi && \
    rm -rf /tmp

# Uygulama kopyalama
COPY ./scripts /scripts
COPY ./app /app
WORKDIR /app

# Kullanıcı ve dizin ayarları
RUN adduser --disabled-password --no-create-home django-user && \
    mkdir -p /vol/web/media && \
    mkdir -p /vol/web/static && \
    chown -R django-user:django-user /vol && \
    chmod -R 755 /vol && \
    chmod -R +x /scripts

# Geçici build bağımlılıklarını temizle
RUN apk del .tmp-build-deps

# Ortam değişkenleri
ENV PATH="/scripts:/py/bin:$PATH"

USER django-user
EXPOSE 8000

CMD ["/scripts/run.sh"]