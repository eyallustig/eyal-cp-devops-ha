ARG PYTHON_VERSION=3.11.8

FROM python:${PYTHON_VERSION}-slim

WORKDIR /app

RUN groupadd -g 999 appuser && \
    useradd -r -u 999 -g appuser appuser

COPY services/api/requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

COPY services/api/ /app/services/api/

RUN chown -R appuser:appuser /app
USER appuser

EXPOSE 8000
CMD ["uvicorn", "services.api.app:app", "--host", "0.0.0.0", "--port", "8000"]
