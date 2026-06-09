import os
import uuid
import logging
import time

from flask import Flask, jsonify, request, g
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
from pythonjsonlogger import jsonlogger

# ── Logging ──────────────────────────────────────────────
logger = logging.getLogger("securebank")
log_handler = logging.StreamHandler()
formatter = jsonlogger.JsonFormatter(
    fmt="%(asctime)s %(levelname)s %(name)s %(message)s",
    rename_fields={"asctime": "timestamp", "levelname": "level"},
)
log_handler.setFormatter(formatter)
logger.addHandler(log_handler)
logger.setLevel(os.environ.get("LOG_LEVEL", "INFO").upper())

# ── Flask App ────────────────────────────────────────────
app = Flask(__name__)

# ── Prometheus Metrics ───────────────────────────────────
REQUEST_COUNT = Counter(
    "securebank_http_requests_total",
    "Total HTTP requests",
    ["method", "endpoint", "status"],
)
REQUEST_LATENCY = Histogram(
    "securebank_http_request_duration_seconds",
    "HTTP request latency in seconds",
    ["method", "endpoint"],
)


@app.before_request
def before_request():
    """Inject request ID and start timer."""
    g.request_id = request.headers.get("X-Request-ID", str(uuid.uuid4()))
    g.start_time = time.perf_counter()


@app.after_request
def after_request(response):
    """Record metrics, add security and tracing headers."""
    # Metrics
    latency = time.perf_counter() - g.start_time
    endpoint = request.path
    REQUEST_COUNT.labels(request.method, endpoint, response.status_code).inc()
    REQUEST_LATENCY.labels(request.method, endpoint).observe(latency)

    # Tracing
    response.headers["X-Request-ID"] = g.request_id

    # Security headers
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["X-Frame-Options"] = "DENY"
    response.headers["X-XSS-Protection"] = "1; mode=block"
    response.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains"
    response.headers["Cache-Control"] = "no-store"

    # Access log
    logger.info(
        "request completed",
        extra={
            "request_id": g.request_id,
            "method": request.method,
            "path": request.path,
            "status": response.status_code,
            "latency_ms": round(latency * 1000, 2),
            "remote_addr": request.remote_addr,
        },
    )
    return response


# ── Health & Readiness ───────────────────────────────────
@app.route("/healthz")
def healthz():
    """Liveness probe — is the process alive?"""
    return jsonify({"status": "healthy"}), 200


@app.route("/readyz")
def readyz():
    """Readiness probe — is the service ready to accept traffic?"""
    # Extend this with dependency checks (DB, cache, etc.) as needed
    return jsonify({"status": "ready"}), 200


@app.route("/")
def root():
    """Root endpoint — basic service info."""
    return jsonify({
        "service": "securebank",
        "status": "ok",
        "version": os.environ.get("APP_VERSION", "1.0.0"),
    })


# ── Business Endpoints ───────────────────────────────────
@app.route("/api/transactions")
def transactions():
    """Return sample transaction data."""
    return jsonify({
        "transactions": [
            {"id": 1001, "amount": 525.12, "currency": "USD", "type": "deposit"},
            {"id": 1002, "amount": -110.50, "currency": "USD", "type": "withdrawal"},
        ]
    })


# ── Prometheus Metrics Endpoint ──────────────────────────
@app.route("/metrics")
def metrics():
    """Expose Prometheus metrics."""
    return generate_latest(), 200, {"Content-Type": CONTENT_TYPE_LATEST}


# ── Error Handlers ───────────────────────────────────────
@app.errorhandler(404)
def not_found(error):
    return jsonify({"error": "not found", "status": 404}), 404


@app.errorhandler(500)
def internal_error(error):
    logger.error("internal server error", extra={"error": str(error)})
    return jsonify({"error": "internal server error", "status": 500}), 500


# ── Entrypoint ───────────────────────────────────────────
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
