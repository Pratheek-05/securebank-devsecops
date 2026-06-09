# Wazuh Integration

This folder is reserved for Wazuh rules, decoders, and alerting policies for SecureBank.

Recommended integration patterns:
- collect Kubernetes audit logs
- enable host-based IDS for EKS worker nodes
- use Wazuh manager to ingest Falco alerts and AWS CloudTrail events
- configure email or Slack alerts for critical security events
