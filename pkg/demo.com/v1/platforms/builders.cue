package platforms

import (
	"guku.io/devx/v1"
	"guku.io/devx/v1/components"
	"guku.io/devx/v1/transformers/compose"
	k8s "guku.io/devx/v1/transformers/kubernetes"
	tfaws "guku.io/devx/v1/transformers/terraform/aws"
)

Builders: v1.#StackBuilder

// prod builder
Builders: prod: drivers: kubernetes: output: "deploy"
Builders: prod: drivers: terraform: output:  "deploy"
Builders: prod: mainflows: [
	{
		pipeline: [k8s.#AddDeployment]
	},
	{
		pipeline: [k8s.#AddReplicas]
	},
	{
		pipeline: [k8s.#AddService]
	},
	{
		pipeline: [tfaws.#AddSSMSecretParameter]
	},
	{
		pipeline: [tfaws.#AddS3Bucket]
	},
]

// dev builder
Builders: dev: drivers: compose: output: "docker-compose.yml"
Builders: dev: mainflows: [
	{
		pipeline: [compose.#AddComposeService]
	},
	{
		pipeline: [compose.#ExposeComposeService]
	},
	{
		pipeline: [compose.#AddComposeVolume]
	},
	{
		pipeline: [compose.#AddS3Bucket]
	},
]

Builders: dev: additionalComponents: {
	myminio: {
		components.#Minio
		minio: {
			urlScheme: "http"
			userKeys: default: {
				accessKey:    "admin"
				accessSecret: "adminadmin"
			}
			url: _
		}
	}
	bucket: s3: {
		url:          myminio.minio.url
		accessKey:    myminio.minio.userKeys.default.accessKey
		accessSecret: myminio.minio.userKeys.default.accessSecret
	}
}
