# Third-party software notices

The demo's original files are licensed under the MIT License; see
[LICENSE](./LICENSE). The following upstream software is used by the demo.
These components are not relicensed by the MIT License.

| Component | Version used | License and upstream notice |
| --- | --- | --- |
| PostgreSQL | 16.6 | [PostgreSQL License](https://www.postgresql.org/about/licence/) |
| Apache Kafka | 3.9.0 | [Apache License 2.0](https://github.com/apache/kafka/blob/3.9.0/LICENSE) |
| Debezium Connect | 3.0.8.Final | [Apache License 2.0](https://github.com/debezium/debezium/blob/main/LICENSE) |
| Apache Iceberg Kafka Connect | 1.9.2 | [Apache License 2.0](https://github.com/apache/iceberg/blob/apache-iceberg-1.9.2/LICENSE) |
| Apache Iceberg REST catalog software (Tabulario image) | 1.6.0 | [Apache License 2.0](https://github.com/apache/iceberg/blob/apache-iceberg-1.6.0/LICENSE) |
| MinIO Server | `RELEASE.2025-09-07T16-13-09Z` | [GNU Affero General Public License v3.0](https://github.com/minio/minio/blob/RELEASE.2025-09-07T16-13-09Z/LICENSE) |
| Trino | 475 | [Apache License 2.0](https://github.com/trinodb/trino/blob/475/LICENSE) |

Docker Compose and the Dockerfiles also use upstream container images and
build tools, including Alpine, AWS CLI, cURL, Go, and Gradle. Container images
may bundle additional software and licenses; this short list is not a
complete inventory of every file or transitive dependency inside those
images. Consult each image's upstream documentation and license files for
those notices.

The Dockerfiles fetch Apache Iceberg and MinIO from their upstream source
repositories and build them; their source code is not vendored in this
repository. If you publish or distribute built images or binaries, review
the applicable upstream license terms and preserve any required notices and
source offers. In particular, MinIO is AGPL-3.0-licensed: distribution of a
MinIO binary/image or making a modified MinIO version available for network
use may carry source-disclosure obligations. This demo does not provide legal
advice or determine whether a particular deployment complies with those
terms.
