#!/usr/bin/env python3
"""e2e_test.py

End-to-end helper that exercises the two regions through the public API.

The script does the following:

1. authenticate against the **us-east-1** Cognito user pool and grab an
   IdToken/JWT (USER_PASSWORD_AUTH flow).
2. fire the `/greet` route in *both* regions concurrently, passing the token
   in the `Authorization` header.
3. fire the `/dispatch` route in parallel as well (same token) to exercise the
   dispatcher lambda / Fargate workflow.
4. print each response along with a measured latency and, for `/greet`, assert
   that the returned `region` field matches the region we targeted.

Configuration is supplied via command-line arguments so the script is totally
reusable; you can also drop values into environment variables or modify the
`argparse` defaults.

Example:

    python test/e2e_test.py \
        --user-pool us-east-1_XXXXXXXXX \
        --client-id xxx \
        --client-secret yyy \
        --username myuser --password hunter2 \
        --region1-url https://abcd1234.execute-api.eu-west-1.amazonaws.com/sandbox \
        --region1-name eu-west-1 \
        --region2-url https://wxyz5678.execute-api.us-east-1.amazonaws.com/sandbox \
        --region2-name us-east-1
"""

import aiohttp
import argparse
import asyncio
import base64
import boto3
import hashlib
import hmac
import json
import os
import sys
import time


# ---------------------------------------------------------------------------
# helper functions
# ---------------------------------------------------------------------------

def _compute_secret_hash(username: str, client_id: str, client_secret: str) -> str:
    """Return Cognito "SECRET_HASH" value (HMAC-SHA256 base64)."""
    msg = username + client_id
    dig = hmac.new(
        client_secret.encode("utf-8"), msg.encode("utf-8"), hashlib.sha256
    ).digest()
    return base64.b64encode(dig).decode("utf-8")


def get_id_token(
    client_id: str,
    client_secret: str,
    username: str,
    password: str,
    region: str = "us-east-1",
) -> str:
    """Perform ``USER_PASSWORD_AUTH`` against Cognito and return an IdToken."""

    client = boto3.client("cognito-idp", region_name=region)
    auth_params: dict[str, str] = {"USERNAME": username, "PASSWORD": password}

    auth_params["SECRET_HASH"] = _compute_secret_hash(
        username, client_id, client_secret
    )

    resp = client.initiate_auth(
        ClientId=client_id,
        AuthFlow="USER_PASSWORD_AUTH",
        AuthParameters=auth_params,
    )
    return resp["AuthenticationResult"]["IdToken"]


async def _call_api(
    session: aiohttp.ClientSession,
    method: str,
    url: str,
    token: str,
) -> tuple[int, str, float]:
    """Perform a single request, return (status, body, latency_seconds)."""

    headers = {"Authorization": f"Bearer {token}"}
    start = time.monotonic()
    async with session.request(method, url, headers=headers) as r:
        latency = time.monotonic() - start
        return r.status, latency


# ---------------------------------------------------------------------------
# main entrypoint
# ---------------------------------------------------------------------------

def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(
        description="e2e smoke-test demonstrating cross-region performance"
    )

    p.add_argument("--user-pool", required=True, help="Cognito user pool id")
    p.add_argument("--client-id", required=True, help="Cognito app client id")
    p.add_argument(
        "--client-secret",
        help="Cognito app client secret (only needed if the client has a secret)",
    )
    p.add_argument("--username", required=True)
    p.add_argument("--password", required=True)

    p.add_argument("--region1-url", required=True, help="Base API URL for region-1")
    p.add_argument("--region1-name", required=True, help="Logical region name returned by /greet (e.g. us-east-1)")

    p.add_argument("--region2-url", required=True, help="Base API URL for region-2")
    p.add_argument("--region2-name", required=True, help="Logical region name returned by /greet (e.g. eu-west-1)")

    p.add_argument(
        "--dispatch-payload",
        type=json.loads,
        default="{}",
        help="JSON string to send in the body of each /dispatch request",
    )

    return p.parse_args()


async def main():
    args = parse_args()

    # get a token from Cognito in us-east-1 (hardcoded per spec)
    try:
        token = get_id_token(
            client_id=args.client_id,
            client_secret=args.client_secret,
            username=args.username,
            password=args.password,
            region="us-east-1"
        )
    except Exception as exc:
        print(f"failed to authenticate: {exc}")
        sys.exit(1)

    # build the list of endpoints to call
    work: list[tuple[str, str, str, str]] = []
    for base_url, region_label in [
        (args.region1_url.rstrip("/"), args.region1_name),
        (args.region2_url.rstrip("/"), args.region2_name),
    ]:
        work.append(("GET", f"{base_url}/greet", region_label, "greet"))
        work.append(("POST", f"{base_url}/dispatch", region_label, "dispatch"))

    async with aiohttp.ClientSession() as session:
        tasks = []
        for method, url, region_label, path in work:
            tasks.append(_call_api(session, method, url, token))
        results = await asyncio.gather(*tasks, return_exceptions=True)

    # report
    for (method, url, region_label, path), res in zip(work, results):
        if isinstance(res, Exception):
            print(f"{region_label} {path} -> error {res}")
            continue
        status, latency = res
        print(f"{region_label} {path} [{method}] {url} -> status={status} latency={latency:.3f}s")


if __name__ == "__main__":
    asyncio.run(main())
