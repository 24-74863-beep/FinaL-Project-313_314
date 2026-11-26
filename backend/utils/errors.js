// Error helpers: bad() makes an error with an HTTP status; fail() turns any error into a JSON response.
const bad = (m, status) => Object.assign(new Error(m), { status: status || 400 });

function fail(res, err) {
  const m = String(err && err.message || err);
  let status = 500, msg = 'Server error: ' + m;
  if (err && err.code === 'ER_DUP_ENTRY') {
    status = 409;
    msg = /username/.test(m) ? 'That username is already taken.' : /plate/.test(m) ? 'A motorcycle with this plate number already exists.' : 'That record already exists.';
  } else if (err && (err.code === 'ER_ROW_IS_REFERENCED_2' || err.code === 'ER_ROW_IS_REFERENCED')) {
    status = 409; msg = 'This record is still used by other records, so it cannot be deleted.';
  } else if (err && (err.code === 'ER_NO_REFERENCED_ROW_2' || err.code === 'ER_NO_REFERENCED_ROW')) {
    status = 400; msg = 'A linked record (customer, motorcycle, mechanic...) no longer exists.';
  } else if (err && err.status) { status = err.status; msg = err.message; }
  else console.error(err);
  res.status(status).json({ error: msg });
}

module.exports = { bad, fail };
