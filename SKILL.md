---
name: jsonplaceholder-connector
description: Governed access to JSONPlaceholder REST API with scoped egress, write gates, and receipt sealing. Reads pass on preflight only; mutating writes pause for operator approval.
runx:
  category: data
---

# JSONPlaceholder Connector

Govern read and write operations against the JSONPlaceholder fake REST API
(https://jsonplaceholder.typicode.com) under explicit scoped egress. Reads
complete immediately after a brief preflight reachability check. Mutating
operations (POST, PUT, PATCH, DELETE) pause for operator approval before
any request leaves the workspace.

This skill wraps jsonplaceholder.typicode.com as a governed tool. It does not
call the API directly — it produces a `jsonplaceholder_plan` artifact that
declares the resource, operation, idempotency key, and gate posture. The
connector adapter is the runtime that executes the plan under the granted
scope and records a sealed receipt on completion.

## Modes

### Read (preflight-gated)

The graph checks the API is reachable, then proceeds without an approval
gate. Get, list, and filter operations fall into this class.

### Mutate (preflight + approval gate)

POST, PUT, PATCH, and DELETE operations add an explicit approval pause
after the preflight reachability check. The plan includes the idempotency
key, resource type, and operation class so the operator can review intent
before the connector adapter executes.

## How it works

1. The agent provides a resource type, operation, and optional payload
2. The preflight step confirms the JSONPlaceholder API is reachable
3. For reads: the plan is approved by default and the adapter executes
4. For writes: the plan pauses for operator approval with intent visible
5. On execution, the adapter calls the API and captures the full response
6. A sealed receipt records the operation, status, and response summary

## Scopes

| Scope | Class |
|-------|-------|
| `jsonplaceholder:read` | GET requests, default-allowed |
| `jsonplaceholder:write` | POST, PUT, PATCH, DELETE; requires approval |

## Harness

Three harness cases are defined:
- `list-posts-ok` — read operation; verifies preflight passes and result is valid JSON array
- `create-post-approval` — write operation; verifies approval gate is present and plan is well-formed
- `bad-resource` — invalid resource name; verifies preflight validation catches it before any API call
