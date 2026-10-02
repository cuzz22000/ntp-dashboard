FROM python:3.13.14-alpine3.23

WORKDIR /app

# 1. Install the default local runtime tools
ARG INSTALL_GPSD_CLIENTS=true
RUN set -eux; \
	apk upgrade --no-cache; \
	apk add --no-cache chrony; \
	if [ "$INSTALL_GPSD_CLIENTS" = "true" ]; then \
		apk add --no-cache gpsd-clients; \
	fi
RUN apk upgrade --no-cache musl && apk add --no-cache gnutls p11-kit expat

# 2. Download Tailwind CSS locally
RUN mkdir -p /app/static && wget -q https://cdn.tailwindcss.com/ -O /app/static/tailwindcss.js

# 3. Install Python requirements
COPY requirements.txt .

RUN apk add --no-cache build-base libffi-dev openssl-dev libcrypto3 libssl3 python3-dev

RUN pip install --no-cache-dir --upgrade "pip==26.1.2" \
    && pip install --no-cache-dir -r requirements.txt

# 4. Copy the app files (.dockerignore will block the junk automatically)
COPY . .

# Set version last so dependency layers are not invalidated on version changes
ARG APP_VERSION=dev
ENV APP_VERSION=${APP_VERSION}

# Match your custom port
EXPOSE 55234

CMD ["python", "app.py"]
