import { NextResponse } from "next/server";
import { syncScores } from "@/lib/scores/sync";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

function isAuthorized(request) {
  const secret = process.env.CRON_SECRET;

  if (!secret) {
    return process.env.NODE_ENV !== "production";
  }

  return request.headers.get("authorization") === `Bearer ${secret}`;
}

async function runSync(request) {
  if (!isAuthorized(request)) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  try {
    const results = await syncScores();
    const failed = results.filter((result) => !result.ok);

    return NextResponse.json(
      { ok: failed.length === 0, results },
      { status: failed.length ? 207 : 200 }
    );
  } catch (error) {
    return NextResponse.json(
      { error: error instanceof Error ? error.message : String(error) },
      { status: 500 }
    );
  }
}

export async function GET(request) {
  return runSync(request);
}

export async function POST(request) {
  return runSync(request);
}
