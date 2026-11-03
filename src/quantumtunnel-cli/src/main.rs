use axum::{routing::get, Json, Router};
use serde_json::{json, Value};

async fn health() -> Json<Value> {
    Json(json!({ "status": "healthy", "no_log_enforced": true }))
}

#[tokio::main]
async fn main() {
    let app = Router::new().route("/healthz", get(health));
    let listener = tokio::net::TcpListener::bind("127.0.0.1:8443").await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
