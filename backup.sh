#!/bin/bash

set -o errexit -o nounset -o pipefail

export AWS_PAGER=""

s3() {
    aws s3 --endpoint="$ENDPOINT" "$@"
}

s3api() {
    aws s3api "$1" --endpoint-url="$ENDPOINT" --bucket "$BUCKET" "${@:2}"
}

pg_dump_database() {
    pg_dump  --no-owner --no-privileges --clean --if-exists --quote-all-identifiers "$DATABASE_URL"
}

upload_to_bucket() {
    s3 cp - "$BUCKET/$(date +%Y/%m/%d/backup-%H-%M-%S.sql.gz)"
}

main() {
    echo "Taking backup and uploading it to S3..."
    pg_dump_database | gzip | upload_to_bucket
    echo "Done."
}

main
