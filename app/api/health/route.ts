import { NextResponse } from "next/server";
import { trace } from "@opentelemetry/api";

export async function GET() {
    const tracer = trace.getTracer("sample-nextjs");

    const span = tracer.startSpan("health-api");
    span.setAttribute("test", "signoz");
    span.end();

    return NextResponse.json({
        status: "ok",
        service: "seller-web",
    });
}