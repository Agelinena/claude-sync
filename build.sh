#!/usr/bin/env bash
# Compila o claude-sync num container Go (não precisa de Go no host; com Go
# 1.23+ instalado, use GO=go ./build.sh). Os executáveis vão para dist/, fora
# do git: eles são publicados nas releases (gh release create vX.Y.Z dist/*).
#
#   ./build.sh                                  # Windows, macOS (Apple Silicon) e Linux
#   TARGETS="windows/arm64 darwin/amd64" ./build.sh   # outros alvos
#   VERSION=0.2.0 ./build.sh                    # versão explícita
#
# Sem cgo: binários estáticos. No Windows, -H windowsgui (sem console).
set -euo pipefail

DIR=$(cd "$(dirname "$0")" && pwd)
OUT="$DIR/dist"; mkdir -p "$OUT"
TARGETS=${TARGETS:-"windows/amd64 darwin/arm64 linux/amd64"}
if [ -z "${VERSION:-}" ]; then
  # Tags: v1.2.3. Sem nenhuma, o commit.
  VERSION=$(git -C "$DIR" describe --tags --match 'v*' --dirty 2>/dev/null | sed 's/^v//' || true)
  [ -n "$VERSION" ] || VERSION=$(git -C "$DIR" rev-parse --short HEAD 2>/dev/null || echo dev)
fi

# OUT_DIR, TARGETS e VERSION chegam pelo ambiente (o caminho pode ter espaços).
script='set -e
go vet ./...
go test ./...
for t in $TARGETS; do
  os=${t%/*}; arch=${t#*/}
  out="$OUT_DIR/claude-sync-$os-$arch"
  flags="-s -w -X main.version=$VERSION"
  if [ "$os" = windows ]; then out="$out.exe"; flags="$flags -H windowsgui"; fi
  GOOS=$os GOARCH=$arch go build -trimpath -ldflags "$flags" -o "$out" .
  echo "  $(basename "$out")"
done'

export TARGETS VERSION
if [ -n "${GO:-}" ]; then
  GOBIN_DIR=$(dirname "$(command -v "$GO")")
  (cd "$DIR" && OUT_DIR="$OUT" CGO_ENABLED=0 GOFLAGS=-buildvcs=false PATH="$GOBIN_DIR:$PATH" sh -c "$script")
else
  docker run --rm -v "$DIR":/src -v "$OUT":/out -w /src \
    -e OUT_DIR=/out -e TARGETS -e VERSION -e CGO_ENABLED=0 -e GOFLAGS=-buildvcs=false \
    golang:1.23.4-bookworm sh -c "$script"
fi
echo "Pronto: $OUT ($VERSION)"
