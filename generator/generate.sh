#!/bin/sh
set -eu

cycle=0
interval=${GENERATOR_INTERVAL:-2}

while :; do
  psql -v ON_ERROR_STOP=1 -q -c "
    INSERT INTO public.orders (customer_name, amount, status)
    VALUES (
      'customer-' || lpad((floor(random() * 100)::int)::text, 3, '0'),
      round((10 + random() * 990)::numeric, 2),
      'new'
    );
  " >/dev/null
  cycle=$((cycle + 1))
  printf 'Inserted synthetic order (cycle %s).\n' "$cycle"

  if [ $((cycle % 3)) -eq 0 ]; then
    psql -v ON_ERROR_STOP=1 -q -c "
      UPDATE public.orders
      SET status = 'updated', updated_at = clock_timestamp()
      WHERE id = (SELECT max(id) FROM public.orders);
    " >/dev/null
    printf 'Updated latest order.\n'
  fi

  if [ $((cycle % 8)) -eq 0 ]; then
    psql -v ON_ERROR_STOP=1 -q -c "
      DELETE FROM public.orders
      WHERE id = (SELECT min(id) FROM public.orders);
    " >/dev/null
    printf 'Deleted oldest order.\n'
  fi

  sleep "$interval"
done
