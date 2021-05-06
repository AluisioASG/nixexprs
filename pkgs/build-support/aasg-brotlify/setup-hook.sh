# Setup hook to compress files in $out with Brotli while keeping the
# originals.
#
# To disable this setup hook, set `dontBrotlify`.

aasgBrotlifyPhase() {
	echo "compressing files with Brotli"
	fd "" "$out" -t f -e html -e css -e js -e css.map -e js.map -X brotli --best
}

if [[ -z "${dontBrotlify:-}" ]]; then
	preDistPhases+=" aasgBrotlifyPhase"
fi
