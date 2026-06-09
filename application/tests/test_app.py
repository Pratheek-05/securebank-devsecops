"""Unit tests for the SecureBank Flask application."""
import json


class TestHealthEndpoints:
    """Tests for health and readiness probes."""

    def test_healthz_returns_200(self, client):
        response = client.get("/healthz")
        assert response.status_code == 200
        data = json.loads(response.data)
        assert data["status"] == "healthy"

    def test_readyz_returns_200(self, client):
        response = client.get("/readyz")
        assert response.status_code == 200
        data = json.loads(response.data)
        assert data["status"] == "ready"

    def test_root_returns_service_info(self, client):
        response = client.get("/")
        assert response.status_code == 200
        data = json.loads(response.data)
        assert data["service"] == "securebank"
        assert data["status"] == "ok"
        assert "version" in data


class TestTransactions:
    """Tests for the transactions endpoint."""

    def test_transactions_returns_list(self, client):
        response = client.get("/api/transactions")
        assert response.status_code == 200
        data = json.loads(response.data)
        assert "transactions" in data
        assert len(data["transactions"]) == 2

    def test_transaction_structure(self, client):
        response = client.get("/api/transactions")
        data = json.loads(response.data)
        txn = data["transactions"][0]
        assert "id" in txn
        assert "amount" in txn
        assert "currency" in txn
        assert "type" in txn


class TestMetrics:
    """Tests for the Prometheus metrics endpoint."""

    def test_metrics_endpoint_returns_200(self, client):
        response = client.get("/metrics")
        assert response.status_code == 200
        assert b"securebank_http_requests_total" in response.data

    def test_metrics_content_type(self, client):
        response = client.get("/metrics")
        assert "text/plain" in response.content_type


class TestSecurityHeaders:
    """Tests for security headers middleware."""

    def test_request_id_header(self, client):
        response = client.get("/")
        assert "X-Request-ID" in response.headers

    def test_custom_request_id_passthrough(self, client):
        custom_id = "test-request-12345"
        response = client.get("/", headers={"X-Request-ID": custom_id})
        assert response.headers["X-Request-ID"] == custom_id

    def test_security_headers_present(self, client):
        response = client.get("/")
        assert response.headers["X-Content-Type-Options"] == "nosniff"
        assert response.headers["X-Frame-Options"] == "DENY"
        assert response.headers["X-XSS-Protection"] == "1; mode=block"
        assert "max-age" in response.headers["Strict-Transport-Security"]


class TestErrorHandlers:
    """Tests for error handling."""

    def test_404_returns_json(self, client):
        response = client.get("/nonexistent-endpoint")
        assert response.status_code == 404
        data = json.loads(response.data)
        assert data["error"] == "not found"
