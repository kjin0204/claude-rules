#!/usr/bin/env bash
# Claude Code status line: model, context usage, estimated cost

input=$(cat)

model_id=$(echo "$input" | jq -r '.model.id // "unknown"')
model=$(echo "$input" | jq -r '.model.display_name // "Unknown"')

used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
ctx_used=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // 0')
ctx_total=$(echo "$input" | jq -r '.context_window.context_window_size // 0')

total_in=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_out=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
cache_write=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
cache_read=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')

# Cost calculation (USD per 1M tokens) — rates chosen by model ID
# Pricing tiers:
#   opus-4 / claude-4-opus           : input $15,  output $75,  cwrite $18.75, cread $1.50
#   sonnet-4 / claude-sonnet-4*      : input $3,   output $15,  cwrite $3.75,  cread $0.30
#   haiku-3-5 / claude-haiku-3-5*    : input $0.80,output $4,   cwrite $1.00,  cread $0.08
#   haiku-3 / claude-3-haiku*        : input $0.25,output $1.25,cwrite $0.30,  cread $0.03
#   fallback (sonnet pricing)        : input $3,   output $15,  cwrite $3.75,  cread $0.30
cost=$(echo "$model_id $total_in $total_out $cache_write $cache_read" | awk '{
  mid = $1; tin = $2; tout = $3; tcw = $4; tcr = $5

  # Select per-million-token rates based on model ID substring matching
  if (mid ~ /opus-4/ || mid ~ /claude-4-opus/) {
    ir = 15.00; or_ = 75.00; cwr = 18.75; crr = 1.50
  } else if (mid ~ /haiku-3-5/ || mid ~ /claude-haiku-3-5/) {
    ir = 0.80;  or_ = 4.00;  cwr = 1.00;  crr = 0.08
  } else if (mid ~ /haiku/ || mid ~ /claude-3-haiku/) {
    ir = 0.25;  or_ = 1.25;  cwr = 0.30;  crr = 0.03
  } else {
    # Default: sonnet-4 pricing
    ir = 3.00;  or_ = 15.00; cwr = 3.75;  crr = 0.30
  }

  total = tin/1000000*ir + tout/1000000*or_ + tcw/1000000*cwr + tcr/1000000*crr
  printf "$%.4f", total
}')

# Build output
out=""

# Model name (dynamic from API response)
out="🤖 $model"

# Context usage
if [ -n "$used_pct" ]; then
  ctx_bar=$(printf "%.0f" "$used_pct")
  out="$out | 📊 ctx: ${ctx_bar}%"
elif [ "$ctx_total" -gt 0 ] 2>/dev/null; then
  ctx_bar=$(awk "BEGIN { printf \"%.0f\", $ctx_used / $ctx_total * 100 }")
  out="$out | 📊 ctx: ${ctx_bar}%"
fi

# Estimated cost
out="$out | 💰 est: $cost"

printf "%s" "$out"
