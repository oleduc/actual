expr
  = priority: priority? percent: percent _ of _ category: name
    { return { type: 'percentage', percent: +percent, category, priority: +priority }}
  / priority: priority? amount: amount _ repeatEvery _ weeks: weekCount _ starting _ starting: date limit: limit?
    { return { type: 'week', amount, weeks, starting, limit, priority: +priority }}
  / priority: priority? amount: amount _ by _ month: month from: spendFrom? repeat: (_ repeatEvery _ repeat)?
    { return {
      type: from ? 'spend' : 'by',
      amount,
      month,
      ...(repeat ? repeat[3] : {}),
      from,
      priority: +priority
    } }
  / priority: priority? monthly: amount limit: limit?
    { return { type: 'simple', monthly, limit, priority: +priority  } } 
  / priority: priority? limit: limit
    { return { type: 'simple', limit , priority: +priority } }
  / priority: priority? schedule _ full:full? name: name
  	{ return { type: 'schedule', name, priority: +priority, full } }
  

repeat 'repeat interval'
  = 'month'i { return { annual: false } }
  / months: d _ 'months'i { return { annual: false, repeat: +months } }
  / 'year'i { return { annual: true } }
  / years: d _ 'years'i { return { annual: true, repeat: +years } }

limit =  _? upTo _ amount: amount _ 'hold'i { return {amount: amount, hold: true } }
        / _? upTo _ amount: amount { return {amount: amount, hold: false } }


weekCount
  = week { return null }
  / n: number _ weeks { return +n }

spendFrom = _ 'spend'i _ 'from'i _ month: month { return month }

week = 'week'i
weeks = 'weeks'i
by = 'by'i
of = 'of'i
repeatEvery = 'repeat'i _ 'every'i
starting = 'starting'i
upTo = 'up'i _ 'to'i
schedule = 'schedule'i
full = 'full'i _ {return true}
priority = '-'i number: number _ {return number}

_ 'space' = ' '+
d 'digit' = [0-9]
number 'number' = $(d+)
amount 'amount' = currencySymbol? _? amount: $(d+ ('.' (d d?)?)?) { return +amount }
percent 'percentage' = percent: $(d+) _? '%' { return +percent }
year 'year' = $(d d d d)
month 'month' = $(year '-' d d)
day 'day' = $(d d)
date = $(month '-' day)
currencySymbol 'currency symbol' = symbol: . & { return /\p{Sc}/u.test(symbol) }

name 'Name' = $([^\r\n\t]+)

