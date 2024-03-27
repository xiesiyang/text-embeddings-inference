use axum::{Extension, Json};
use serde::Serialize;
use tracing::instrument;
use crate::Info;

#[derive(Clone, Debug, Serialize)]
#[cfg_attr(feature = "http", derive(utoipa::ToSchema))]
pub struct ModelsInfo {
    pub object: String,
    pub data: Vec<ModelInfo>,
}

#[derive(Clone, Debug, Serialize)]
pub struct ModelInfo {
    pub id: String,
    pub object: String,
    pub owned_by: String,
    pub created: usize,
}

#[utoipa::path(
get,
tag = "Text Embeddings Inference",
path = "/v1/models",
responses((status = 200, description = "Served model info", body = ModelsInfo))
)]
#[instrument]
pub async fn get_models(info: Extension<Info>) -> Json<ModelsInfo> {
    let full_model_id = info.0.model_id;
    let mut model_info = Vec::new();
    let mut model_id = full_model_id.clone();
    if let Some(last_segment) = full_model_id.split('/').last() {
        model_id = last_segment.to_string();
    }

    model_info.push(ModelInfo {
        id: model_id,
        object: "model".to_string(),
        created: 0,
        owned_by: "".to_string(),
    });
    let models = ModelsInfo {
        object: "list".to_string(),
        data: model_info,
    };
    Json(models)
}