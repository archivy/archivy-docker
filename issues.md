# Issues

This file lists all issues encountered in the building and testing of the Archivy image.

Elasticsearch version >= `6.0` on `arm/v6` and `arm/v7` will not start unless `xpack.ml.enabled` is set to `false` in the `docker-compose-with-elasticsearch.yml` file. There are no such issues on other architectures.
