import { registerOTel } from "@vercel/otel";
import { diag, DiagConsoleLogger, DiagLogLevel } from "@opentelemetry/api";

// Switch this to DEBUG temporarily so you can see the spans leaving your machine live!
diag.setLogger(new DiagConsoleLogger(), DiagLogLevel.DEBUG);

export function register() {
    registerOTel({
        serviceName: process.env.OTEL_SERVICE_NAME || "seller-web",
    });
}